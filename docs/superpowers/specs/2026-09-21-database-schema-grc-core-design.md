# Design Specification: GRC Core Database Schema & Domain Data Model

**Date:** 2026-09-21  
**Status:** In Review  
**Architect:** Antigravity (Lead Systems Architect)  
**Collaborating AIs:** Codex, OpenCode, Cursor, Antigravity  

---

## 1. Executive Summary & Problem Context

Themis requires a robust relational database schema and domain model in PostgreSQL managed via Prisma ORM to power its Governance, Risk, and Compliance (GRC) workflow.

### 1.1 Context & Inputs
1. **Legacy Flat Dataset (`historic(in).csv`)**:
   - 1,352 historical risk-control assessments across 263 unique processes.
   - 3 Operating Companies: `General de Salud` (GSA), `General de Seguros` (GSE), and `Reaseguradora Patria` (PR).
   - 66 Functional Areas and 62 Liable Process Owners.
   - Hierarchical operational risk taxonomy (Category / Subcategory / Leaf).
   - Classification flags: `lost` (0 = non-losable operational/compliance risk; 1 = losable financial risk).
   - Frequency scale (`rara`, `poco frecuente`, `frecuente`, `muy frecuente`, `casi cierta`).
   - Severity scale (`insignificante`, `bajo`, `medio`, `alto`, `critico`).
   - Control frequencies (`Diario`, `Semanal`, `Quincenal`, `Mensual`, `Trimestral`, `Anual`, `Por Transacción`, `Sin Control`).
2. **Company Severity Thresholds (`SEVERIDADES X COMPAÑIA - 2022.txt`)**:
   - Each company maintains an annual **Requerimiento de Capital Operativo (RCOP)** defining economic materiality tiers:
     - **Crítico:** $> 10\%$ of RCOP
     - **Alto:** $1\% - 10\%$ of RCOP
     - **Medio:** $0.1\% - 1\%$ of RCOP
     - **Bajo:** $0.01\% - 0.1\%$ of RCOP
     - **Insignificante:** $0 - 0.01\%$ of RCOP

---

## 2. Core Functional Requirements & Workflow Invariants

```
+--------------------------------------------------------------------------------------------------+
|                                    GRC PROCESS LIFECYCLE                                         |
+--------------------------------------------------------------------------------------------------+
                                                 |
  1. Process Creation (Company, Area, Liable)   v
  +-----------------------------------------------------------------------------------------------+
  | Status: DRAFT -> Liable notified via Hermes -> Meeting held (Logged on Timeline)              |
  +-----------------------------------------------------------------------------------------------+
                                                 |
  2. Risk Identification & Assessment            v
  +-----------------------------------------------------------------------------------------------+
  | Risk User & Liable define N Risks:                                                            |
  | - Frequency (1..5) x Severity (1..5) -> Grade (Heatmap Matrix)                                |
  | - isLosable flag (Boolean: financial loss exposure vs non-financial)                          |
  | - Taxonomy Leaf Node                                                                          |
  +-----------------------------------------------------------------------------------------------+
                                                 |
  3. Control Definition & Mapping                v
  +-----------------------------------------------------------------------------------------------+
  | Risk User defines Controls (code, description, frequency: DAILY..PER_TRANSACTION).            |
  | Links Controls to Risks (Many-to-Many via RiskControlMitigation).                             |
  | Status: PENDING_APPROVAL                                                                      |
  +-----------------------------------------------------------------------------------------------+
                                                 |
  4. Control Approval / Feedback Loop            v
  +-----------------------------------------------------------------------------------------------+
  | Liable reviews each Control:                                                                  |
  | - APPROVED -> Status updated to APPROVED                                                      |
  | - CHANGES_REQUESTED -> Requires mandatory Liable feedback comment; Risk user amends control   |
  | Loop repeats until 100% of controls are APPROVED.                                            |
  +-----------------------------------------------------------------------------------------------+
                                                 |
  5. Process Closure                             v
  +-----------------------------------------------------------------------------------------------+
  | Process transitions to APPROVED. Overall Process Grade calculated.                            |
  | Read-only access granted to Liable and Authorized Viewers (sub-liables).                      |
  +-----------------------------------------------------------------------------------------------+
                                                 |
  6. Process Migration & Versioning (On Expiry or Changes)                                        |
  +-----------------------------------------------------------------------------------------------+
  | - New Process instantiated with `migratedFromId = oldProcess.id`, `version = v + 1`.          |
  | - Old Process archived as MIGRATED (immutable).                                               |
  | - Selective Migration options: FULL, ONLY_CONTROLS, ONLY_RISKS, METADATA_ONLY.                |
  | - Full lineage and migration reason logged in Timeline and ProcessMigrationLog.               |
  +-----------------------------------------------------------------------------------------------+
```

---

## 3. Database Entity Specifications

### 3.1 Organizational & Access Model
1. **`Company`**:
   - `id`: UUID (Primary Key).
   - `code`: String (Unique, e.g., `GSE`, `GSA`, `PR`).
   - `name`: String (e.g., `General de Seguros, S.A.`).
   - `isActive`: Boolean (Default: `true`).
2. **`CompanyCapitalRequirement`**:
   - `id`: UUID (Primary Key).
   - `companyId`: UUID (FK to `Company`).
   - `year`: Int (e.g., `2022`, `2026`).
   - `rcopAmount`: Decimal(18, 2) (The baseline Operational Capital Requirement).
   - `insignificantMin`: Decimal(18, 2) (Default `0.00`).
   - `insignificantMax`: Decimal(18, 2) ($0.01\%$ RCOP).
   - `lowMax`: Decimal(18, 2) ($0.1\%$ RCOP).
   - `mediumMax`: Decimal(18, 2) ($1.0\%$ RCOP).
   - `highMax`: Decimal(18, 2) ($10.0\%$ RCOP).
   - `criticalMin`: Decimal(18, 2) ($> 10.0\%$ RCOP).
   - Unique constraint: `[companyId, year]`.
3. **`Area`**:
   - `id`: UUID (Primary Key).
   - `companyId`: UUID (FK to `Company`).
   - `name`: String (e.g., `Subdirección Daños Contratos`).
   - `code`: String (Optional area identifier).
4. **`User`**:
   - `id`: UUID (Primary Key).
   - `email`: String (Unique).
   - `fullName`: String.
   - `role`: Enum `UserRole` (`ADMIN`, `RISK_MANAGER`, `LIABLE`, `VIEWER`).
   - `companyId`: UUID (FK to `Company`, optional for global admins).
   - `isActive`: Boolean (Default `true`).
5. **`ProcessViewer` (Sub-Liables & Authorized Viewers)**:
   - `id`: UUID (Primary Key).
   - `processId`: UUID (FK to `Process`).
   - `userId`: UUID (FK to `User`).
   - `role`: Enum `ViewerRole` (`SUB_LIABLE`, `STAKEHOLDER`, `AUDITOR`).
   - Unique constraint: `[processId, userId]`.

---

### 3.2 Operational Risk Taxonomy (`TaxonomyNode`)
To support the hierarchical categories found in historical data (e.g., *Ejecución, Entrega y Gestión de Procesos $\rightarrow$ Gestión de Cuentas de Clientes $\rightarrow$ Entrega de información inadecuada*):
- `id`: UUID (Primary Key).
- `parentId`: UUID (Nullable, self-referencing FK to `TaxonomyNode`).
- `name`: String (Category or subcategory label).
- `code`: String (Optional reference code).
- `level`: Int (1 = Category, 2 = Subcategory, 3 = Leaf Risk Type).
- `fullPath`: String (Denormalized path for fast indexing and text searches).
- `isActive`: Boolean (Default `true`).

---

### 3.3 Process Aggregate (`Process`)
- `id`: UUID (Primary Key).
- `code`: String (Unique business identifier, e.g., `PROC-PR-2026-001`).
- `name`: String.
- `companyId`: UUID (FK to `Company`).
- `areaId`: UUID (FK to `Area`).
- `liableId`: UUID (FK to `User` with liable role).
- `status`: Enum `ProcessStatus`:
  - `DRAFT`: Initial creation, awaiting risk meeting.
  - `IN_REVIEW`: Risk assessment and control definition underway.
  - `PENDING_APPROVAL`: Controls proposed, awaiting Liable review.
  - `APPROVED`: 100% of controls approved; process fully active.
  - `MIGRATED`: Replaced by a newer version/process through migration.
  - `EXPIRED`: Process reached end of validity without renewal.
- `overallGrade`: Enum `RiskGrade` (`INSIGNIFICANT`, `LOW`, `MEDIUM`, `HIGH`, `CRITICAL`, nullable until calculated).
- `version`: Int (Starts at 1, incremented upon migration).
- `migratedFromId`: UUID (Nullable, self-referencing FK to prior `Process`).
- `createdAt`: Timestamp with timezone (Default `now()`).
- `updatedAt`: Timestamp with timezone (Auto-updated).
- `approvedAt`: Timestamp with timezone (Nullable).

---

### 3.4 Risk Aggregate (`Risk`)
- `id`: UUID (Primary Key).
- `processId`: UUID (FK to `Process`, `onDelete: Cascade`).
- `description`: String (Text of the risk event).
- `frequency`: Enum `RiskFrequency`:
  - `RARE` (1, Rara)
  - `UNLIKELY` (2, Poco frecuente)
  - `POSSIBLE` (3, Frecuente / Moderada)
  - `LIKELY` (4, Muy frecuente)
  - `ALMOST_CERTAIN` (5, Casi cierta)
- `severity`: Enum `RiskSeverity`:
  - `INSIGNIFICANT` (1, Insignificante)
  - `LOW` (2, Bajo)
  - `MEDIUM` (3, Medio)
  - `HIGH` (4, Alto)
  - `CRITICAL` (5, Crítico)
- `grade`: Enum `RiskGrade`:
  - `INSIGNIFICANT`, `LOW`, `MEDIUM`, `HIGH`, `CRITICAL`.
  - Automatically derived via the Risk Heatmap Matrix upon save.
- `isLosable`: Boolean (Default `false`). Reflects whether the risk can materialize in quantifiable direct financial loss (`lost = 1` in legacy data).
- `taxonomyNodeId`: UUID (FK to `TaxonomyNode`, pointing to the leaf risk taxonomy).
- `createdAt`: Timestamp with timezone.
- `updatedAt`: Timestamp with timezone.

---

### 3.5 Control Aggregate (`Control`)
- `id`: UUID (Primary Key).
- `processId`: UUID (FK to `Process`, `onDelete: Cascade`).
- `code`: String (e.g., `CTRL-001`).
- `description`: String (Detailed description of the mitigating control).
- `frequency`: Enum `ControlFrequency`:
  - `DAILY` (Diario)
  - `WEEKLY` (Semanal)
  - `BIWEEKLY` (Quincenal)
  - `MONTHLY` (Mensual)
  - `QUARTERLY` (Trimestral)
  - `ANNUALLY` (Anual)
  - `PER_TRANSACTION` (Por Transacción)
  - `NO_CONTROL` (Sin Control)
- `status`: Enum `ControlStatus`:
  - `PENDING_APPROVAL`: Proposed by risk team, pending Liable evaluation.
  - `CHANGES_REQUESTED`: Rejected by Liable with required feedback comment.
  - `APPROVED`: Accepted by Liable.
- `createdAt`: Timestamp with timezone.
- `updatedAt`: Timestamp with timezone.

---

### 3.6 Relationships & Junctions
1. **`RiskControlMitigation`**:
   - `id`: UUID (Primary Key).
   - `riskId`: UUID (FK to `Risk`, `onDelete: Cascade`).
   - `controlId`: UUID (FK to `Control`, `onDelete: Cascade`).
   - `mitigationWeight`: Decimal(5, 2) (Default `1.00`, allows weighting multi-control mitigations).
   - Unique constraint: `[riskId, controlId]`.
2. **`ControlChangeRequest` (Liable Feedback Thread)**:
   - `id`: UUID (Primary Key).
   - `controlId`: UUID (FK to `Control`, `onDelete: Cascade`).
   - `liableId`: UUID (FK to `User`).
   - `comment`: String (The explanation and requested modification).
   - `status`: Enum `ChangeRequestStatus` (`PENDING`, `RESOLVED`, `DISMISSED`).
   - `requestedAt`: Timestamp with timezone (Default `now()`).
   - `resolvedAt`: Timestamp with timezone (Nullable).
   - `resolutionNotes`: String (Optional explanation by risk user of the amendment made).

---

### 3.7 Process Timeline & Audit History
1. **`ProcessTimelineEvent`**:
   - `id`: UUID (Primary Key).
   - `processId`: UUID (FK to `Process`, `onDelete: Cascade`).
   - `eventType`: Enum `TimelineEventType`:
     - `PROCESS_CREATED`
     - `LIABLE_ASSIGNED`
     - `MEETING_HELD` (Records risk assessment meeting between Liable and Risk user)
     - `RISK_ADDED`
     - `RISK_UPDATED`
     - `CONTROL_PROPOSED`
     - `CONTROL_CHANGES_REQUESTED`
     - `CONTROL_APPROVED`
     - `PROCESS_APPROVED`
     - `PROCESS_MIGRATED`
   - `title`: String.
   - `description`: String.
   - `metadata`: JSONB (Stores diffs, meeting notes, or changed attributes).
   - `actorId`: UUID (FK to `User`).
   - `createdAt`: Timestamp with timezone (Default `now()`).
2. **`ProcessMigrationLog`**:
   - `id`: UUID (Primary Key).
   - `sourceProcessId`: UUID (FK to `Process`).
   - `targetProcessId`: UUID (FK to `Process`).
   - `migrationScope`: Enum `MigrationScope`:
     - `FULL` (Both risks and controls copied).
     - `ONLY_CONTROLS` (Only controls copied; risks redefined).
     - `ONLY_RISKS` (Only risks copied; controls redefined).
     - `METADATA_ONLY` (Fresh start with name/liable adjustments).
   - `reason`: String.
   - `performedById`: UUID (FK to `User`).
   - `createdAt`: Timestamp with timezone (Default `now()`).

---

## 4. Business Logic & Calculation Specifications

### 4.1 Risk Heatmap Grade Matrix
Calculated automatically when a Risk is saved:

| Frequency \ Severity | Insignificante (1) | Bajo (2) | Medio (3) | Alto (4) | Crítico (5) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Casi cierta (5)** | Bajo | Bajo | Medio | Crítico | Crítico |
| **Muy frecuente (4)** | Insignificante | Bajo | Medio | Crítico | Crítico |
| **Frecuente (3)** | Insignificante | Bajo | Medio | Alto | Crítico |
| **Poco frecuente (2)** | Insignificante | Insignificante / Bajo | Medio | Alto | Crítico |
| **Rara (1)** | Insignificante | Insignificante | Bajo | Medio | Alto |

*Note: In the domain entity `Risk`, a pure lookup function maps `(frequency, severity) => RiskGrade`.*

### 4.2 Overall Process Grade Formula
When all controls are approved, the overall process grade is calculated as the rounded arithmetic mean of individual risk grades:
$$\text{NumericGrade}(g) = \begin{cases} 1 & \text{INSIGNIFICANT} \\ 2 & \text{LOW} \\ 3 & \text{MEDIUM} \\ 4 & \text{HIGH} \\ 5 & \text{CRITICAL} \end{cases}$$
$$\text{MeanScore} = \frac{1}{N} \sum_{i=1}^N \text{NumericGrade}(r_i.\text{grade})$$
$$\text{OverallProcessGrade} = \text{GradeFromNumeric}(\text{round}(\text{MeanScore}))$$

### 4.3 Economic Severity Dashboard Calculations
Risk managers can filter monthly portfolios by company or portfolio-wide:
- **Filters**: `companyId` (optional), `year`, `month`, `isLosable` (true = losable, false = non-losable).
- **Valuation Logic**:
  - Each severity level is evaluated against the `CompanyCapitalRequirement` for that company and year.
  - **Representative Monetary Exposure Benchmark**:
    - $\text{Insignificant} = \frac{\text{insignificantMax}}{2}$
    - $\text{Low} = \frac{\text{insignificantMax} + \text{lowMax}}{2}$
    - $\text{Medium} = \frac{\text{lowMax} + \text{mediumMax}}{2}$
    - $\text{High} = \frac{\text{mediumMax} + \text{highMax}}{2}$
    - $\text{Critical} = \text{criticalMin} \times 1.25$
- Monthly aggregations compute:
  - Total Losable Risk Count & Estimated Economic Exposure ($\sum \text{Benchmark}$)
  - Total Non-Losable Risk Count & Exposure Distribution

---

## 5. Complete Prisma Schema Representation

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

enum UserRole {
  ADMIN
  RISK_MANAGER
  LIABLE
  VIEWER
}

enum ViewerRole {
  SUB_LIABLE
  STAKEHOLDER
  AUDITOR
}

enum ProcessStatus {
  DRAFT
  IN_REVIEW
  PENDING_APPROVAL
  APPROVED
  MIGRATED
  EXPIRED
}

enum RiskFrequency {
  RARE
  UNLIKELY
  POSSIBLE
  LIKELY
  ALMOST_CERTAIN
}

enum RiskSeverity {
  INSIGNIFICANT
  LOW
  MEDIUM
  HIGH
  CRITICAL
}

enum RiskGrade {
  INSIGNIFICANT
  LOW
  MEDIUM
  HIGH
  CRITICAL
}

enum ControlFrequency {
  DAILY
  WEEKLY
  BIWEEKLY
  MONTHLY
  QUARTERLY
  ANNUALLY
  PER_TRANSACTION
  NO_CONTROL
}

enum ControlStatus {
  PENDING_APPROVAL
  CHANGES_REQUESTED
  APPROVED
}

enum ChangeRequestStatus {
  PENDING
  RESOLVED
  DISMISSED
}

enum TimelineEventType {
  PROCESS_CREATED
  LIABLE_ASSIGNED
  MEETING_HELD
  RISK_ADDED
  RISK_UPDATED
  CONTROL_PROPOSED
  CONTROL_CHANGES_REQUESTED
  CONTROL_APPROVED
  PROCESS_APPROVED
  PROCESS_MIGRATED
}

enum MigrationScope {
  FULL
  ONLY_CONTROLS
  ONLY_RISKS
  METADATA_ONLY
}

model Company {
  id                  String                      @id @default(uuid()) @db.Uuid
  code                String                      @unique
  name                String
  isActive            Boolean                     @default(true)
  areas               Area[]
  users               User[]
  processes           Process[]
  capitalRequirements CompanyCapitalRequirement[]
  createdAt           DateTime                    @default(now())
  updatedAt           DateTime                    @updatedAt

  @@map("companies")
}

model CompanyCapitalRequirement {
  id               String   @id @default(uuid()) @db.Uuid
  companyId        String   @db.Uuid
  year             Int
  rcopAmount       Decimal  @db.Decimal(18, 2)
  insignificantMin Decimal  @default(0.00) @db.Decimal(18, 2)
  insignificantMax Decimal  @db.Decimal(18, 2)
  lowMax           Decimal  @db.Decimal(18, 2)
  mediumMax        Decimal  @db.Decimal(18, 2)
  highMax          Decimal  @db.Decimal(18, 2)
  criticalMin      Decimal  @db.Decimal(18, 2)
  createdAt        DateTime @default(now())
  updatedAt        DateTime @updatedAt

  company Company @relation(fields: [companyId], references: [id], onDelete: Cascade)

  @@unique([companyId, year])
  @@map("company_capital_requirements")
}

model Area {
  id        String    @id @default(uuid()) @db.Uuid
  companyId String    @db.Uuid
  name      String
  code      String?
  processes Process[]
  company   Company   @relation(fields: [companyId], references: [id], onDelete: Cascade)
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt

  @@map("areas")
}

model User {
  id                     String                 @id @default(uuid()) @db.Uuid
  email                  String                 @unique
  fullName               String
  role                   UserRole               @default(VIEWER)
  companyId              String?                @db.Uuid
  isActive               Boolean                @default(true)
  company                Company?               @relation(fields: [companyId], references: [id])
  liableProcesses        Process[]              @relation("ProcessLiable")
  viewingProcesses       ProcessViewer[]
  timelineEvents         ProcessTimelineEvent[]
  changeRequestsCreated  ControlChangeRequest[]
  migrationsInitiated    ProcessMigrationLog[]  @relation("MigrationPerformer")
  createdAt              DateTime               @default(now())
  updatedAt              DateTime               @updatedAt

  @@map("users")
}

model TaxonomyNode {
  id        String         @id @default(uuid()) @db.Uuid
  parentId  String?        @db.Uuid
  name      String
  code      String?
  level     Int
  fullPath  String
  isActive  Boolean        @default(true)
  parent    TaxonomyNode?  @relation("TaxonomyTree", fields: [parentId], references: [id])
  children  TaxonomyNode[] @relation("TaxonomyTree")
  risks     Risk[]
  createdAt DateTime       @default(now())
  updatedAt DateTime       @updatedAt

  @@index([parentId])
  @@index([fullPath])
  @@map("taxonomy_nodes")
}

model Process {
  id             String                 @id @default(uuid()) @db.Uuid
  code           String                 @unique
  name           String
  companyId      String                 @db.Uuid
  areaId         String                 @db.Uuid
  liableId       String                 @db.Uuid
  status         ProcessStatus          @default(DRAFT)
  overallGrade   RiskGrade?
  version        Int                    @default(1)
  migratedFromId String?                @db.Uuid
  migratedFrom   Process?               @relation("ProcessLineage", fields: [migratedFromId], references: [id])
  migratedTo     Process[]              @relation("ProcessLineage")
  company        Company                @relation(fields: [companyId], references: [id])
  area           Area                   @relation(fields: [areaId], references: [id])
  liable         User                   @relation("ProcessLiable", fields: [liableId], references: [id])
  risks          Risk[]
  controls       Control[]
  viewers        ProcessViewer[]
  timelineEvents ProcessTimelineEvent[]
  outgoingMigrations ProcessMigrationLog[] @relation("SourceMigration")
  incomingMigrations ProcessMigrationLog[] @relation("TargetMigration")
  approvedAt     DateTime?
  createdAt      DateTime               @default(now())
  updatedAt      DateTime               @updatedAt

  @@index([companyId])
  @@index([areaId])
  @@index([liableId])
  @@index([status])
  @@map("processes")
}

model ProcessViewer {
  id        String     @id @default(uuid()) @db.Uuid
  processId String     @db.Uuid
  userId    String     @db.Uuid
  role      ViewerRole @default(SUB_LIABLE)
  process   Process    @relation(fields: [processId], references: [id], onDelete: Cascade)
  user      User       @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([processId, userId])
  @@map("process_viewers")
}

model Risk {
  id             String                 @id @default(uuid()) @db.Uuid
  processId      String                 @db.Uuid
  description    String                 @db.Text
  frequency      RiskFrequency
  severity       RiskSeverity
  grade          RiskGrade
  isLosable      Boolean                @default(false)
  taxonomyNodeId String                 @db.Uuid
  process        Process                @relation(fields: [processId], references: [id], onDelete: Cascade)
  taxonomyNode   TaxonomyNode           @relation(fields: [taxonomyNodeId], references: [id])
  mitigations    RiskControlMitigation[]
  createdAt      DateTime               @default(now())
  updatedAt      DateTime               @updatedAt

  @@index([processId])
  @@index([isLosable])
  @@index([grade])
  @@map("risks")
}

model Control {
  id             String                 @id @default(uuid()) @db.Uuid
  processId      String                 @db.Uuid
  code           String
  description    String                 @db.Text
  frequency      ControlFrequency
  status         ControlStatus          @default(PENDING_APPROVAL)
  process        Process                @relation(fields: [processId], references: [id], onDelete: Cascade)
  mitigations    RiskControlMitigation[]
  changeRequests ControlChangeRequest[]
  createdAt      DateTime               @default(now())
  updatedAt      DateTime               @updatedAt

  @@index([processId])
  @@index([status])
  @@map("controls")
}

model RiskControlMitigation {
  id               String   @id @default(uuid()) @db.Uuid
  riskId           String   @db.Uuid
  controlId        String   @db.Uuid
  mitigationWeight Decimal  @default(1.00) @db.Decimal(5, 2)
  risk             Risk     @relation(fields: [riskId], references: [id], onDelete: Cascade)
  control          Control  @relation(fields: [controlId], references: [id], onDelete: Cascade)

  @@unique([riskId, controlId])
  @@map("risk_control_mitigations")
}

model ControlChangeRequest {
  id              String              @id @default(uuid()) @db.Uuid
  controlId       String              @db.Uuid
  liableId        String              @db.Uuid
  comment         String              @db.Text
  status          ChangeRequestStatus @default(PENDING)
  resolutionNotes String?             @db.Text
  requestedAt     DateTime            @default(now())
  resolvedAt      DateTime?
  control         Control             @relation(fields: [controlId], references: [id], onDelete: Cascade)
  liable          User                @relation(fields: [liableId], references: [id])

  @@index([controlId])
  @@map("control_change_requests")
}

model ProcessTimelineEvent {
  id          String            @id @default(uuid()) @db.Uuid
  processId   String            @db.Uuid
  eventType   TimelineEventType
  title       String
  description String            @db.Text
  metadata    Json?             @db.JsonB
  actorId     String            @db.Uuid
  actor       User              @relation(fields: [actorId], references: [id])
  process     Process           @relation(fields: [processId], references: [id], onDelete: Cascade)
  createdAt   DateTime          @default(now())

  @@index([processId, createdAt])
  @@map("process_timeline_events")
}

model ProcessMigrationLog {
  id              String         @id @default(uuid()) @db.Uuid
  sourceProcessId String         @db.Uuid
  targetProcessId String         @db.Uuid
  migrationScope  MigrationScope
  reason          String         @db.Text
  performedById   String         @db.Uuid
  sourceProcess   Process        @relation("SourceMigration", fields: [sourceProcessId], references: [id])
  targetProcess   Process        @relation("TargetMigration", fields: [targetProcessId], references: [id])
  performedBy     User           @relation("MigrationPerformer", fields: [performedById], references: [id])
  createdAt       DateTime       @default(now())

  @@map("process_migration_logs")
}
```

---

## 6. S.O.L.I.D. & Clean Architecture Alignment (`apps/olympus`)

- **Domain Layer (`domain/`)**:
  - `Process`, `Risk`, `Control`, `TaxonomyNode`, `CompanyCapitalRequirement` entities.
  - Value Objects: `RiskGrade`, `RiskScore`, `SeverityThresholds`.
  - Pure domain functions: `calculateRiskGrade(frequency, severity)`, `calculateProcessOverallGrade(risks)`.
- **Application Layer (`services/`)**:
  - `CreateProcessUseCase`: Initializes process, notifies liable via `Hermes`.
  - `ProposeControlsUseCase`: Links controls to risks within the process.
  - `ReviewControlUseCase`: Liable marks `APPROVED` or `CHANGES_REQUESTED` with mandatory comments. Checks if 100% of controls are approved to trigger process closure.
  - `MigrateProcessUseCase`: Handles selective migration (`FULL`, `ONLY_CONTROLS`, `ONLY_RISKS`, `METADATA_ONLY`), creates new version, archives old, writes to `ProcessMigrationLog` and `ProcessTimelineEvent`.
- **Infrastructure Layer (`infrastructure/`)**:
  - `PrismaProcessRepository`, `PrismaRiskRepository`, `PrismaControlRepository` implementing domain repository interfaces.

---

## 7. Verification & Migration Checklist

1. **Schema Validation**:
   - `pnpm prisma validate` on Olympus schema.
2. **Seed Migration Test**:
   - Verify historical import from `historic(in).csv`:
     - 3 Companies (`GSE`, `GSA`, `PR`).
     - 66 Areas.
     - 62 Liables.
     - 263 Processes.
     - 1,348 Risks with correct taxonomy hierarchy and heatmap grades.
     - Capital requirements from `SEVERIDADES X COMPAÑIA - 2022.txt` seeded into `CompanyCapitalRequirement`.
3. **Workflow Integration Tests**:
   - Test control rejection loop with liable comment.
   - Test auto-approval of process once the final control transitions to `APPROVED`.
   - Test selective migration: verify that selecting `ONLY_CONTROLS` produces a new process containing the exact controls reset to `PENDING_APPROVAL`, with 0 risks, and archives the parent process.
