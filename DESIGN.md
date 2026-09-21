# DESIGN.md: Themis GRC Platform Specification & Architecture

**Themis** is a modern, enterprise-grade Governance, Risk, and Compliance (GRC) platform developed as a portfolio showcase. It embodies clean engineering, rigorous S.O.L.I.D. design principles, and cryptographic integrity to solve the operational friction of continuous compliance.

---

## 1. Executive Summary & Product Vision

### Context & Problem
Modern enterprises are overwhelmed by overlapping security standards (ISO 27001, SOC 2, NIST CSF, HIPAA, GDPR). Compliance teams struggle with:
*   **Duplicate Work:** Manually gathering the same evidence for 5 different audits.
*   **Stale Risk Registers:** Spreadsheets that do not dynamically recalculate residual risk when controls fail.
*   **Unreliable Audit Trails:** Logs that can be modified or deleted without detection.
*   **Clunky Interfaces:** Legacy GRC tools characterized by confusing enterprise bloat.

### The Themis Solution
Themis provides a unified compliance and risk management operating system:
*   **Unified Control Harmonization:** Map once, satisfy many frameworks.
*   **Live Risk Scoring Engine:** Mathematical risk quantification with automatic residual risk adjustments.
*   **Tamper-Evident Cryptographic Ledger:** SHA-256 chained audit entries guaranteeing non-repudiation.
*   **Impeccable Modern UI:** High-density, keyboard-navigable interface built with React 19, Shadcn UI, Zustand, and smooth view transitions.

---

## 2. Architectural Blueprint (Clean Architecture & S.O.L.I.D.)

Themis strictly separates concerns into 4 concentric layers. High-level policies never depend on low-level implementation details.

```
+-----------------------------------------------------------------------+
|  Presentation Layer (`src/presentation/`)                             |
|  - React 19 Components (Shadcn UI + Radix / Base UI primitives)       |
|  - Zustand Feature Slices (Client UI State & Filters)                 |
|  - TanStack Query Hooks (Server State & Optimistic Caches)            |
|  - Smooth Navigation Transitions (@vercel/react-view-transitions)     |
+-----------------------------------+-----------------------------------+
                                    |
                                    v
+-----------------------------------------------------------------------+
|  Application Layer (`src/application/`)                               |
|  - Use Cases / Interactors (AssessRisk, VerifyControl, SignAuditLog)   |
|  - DTOs & Output Contracts                                            |
|  - Service Interfaces & Ports (IAuditSigner, INotificationBroker)      |
+-----------------------------------+-----------------------------------+
                                    |
                                    v
+-----------------------------------------------------------------------+
|  Domain Layer (`src/domain/`)                                         |
|  - Aggregates & Entities: Framework, Control, Risk, Evidence, Audit   |
|  - Value Objects: RiskScore, ControlCode, Status, HashChain           |
|  - Domain Exceptions & Event Emitters                                 |
|  - Repository Interfaces (IRiskRepository, IControlRepository)        |
+-----------------------------------+-----------------------------------+
                                    ^
                                    | (implements interfaces)
+-----------------------------------+-----------------------------------+
|  Infrastructure Layer (`src/infrastructure/`)                         |
|  - Repository Implementations (IndexedDB / LocalStorage / Postgres)   |
|  - Cryptographic Engines (WebCrypto SHA-256 Chain Signer)             |
|  - External Data Connectors & Compliance Ingestion Mock Adapters      |
+-----------------------------------------------------------------------+
```

---

## 3. Core Domain Models & Business Logic

### 3.1 Compliance Framework Aggregate
*   **Entities:** `Framework`, `Section`, `ControlRequirement`.
*   **Standards Covered:**
    *   *ISO/IEC 27001:2022* (Organizational, People, Physical, Technological)
    *   *SOC 2 Type II* (Trust Services Criteria CC1.0 - CC9.0)
    *   *NIST CSF 2.0* (Govern, Identify, Protect, Detect, Respond, Recover)
    *   *HIPAA Security Rule* (§164.308, §164.310, §164.312)
    *   *GDPR* (Articles 25, 30, 32, 33, 34)

### 3.2 Unified Control Entity
*   `Control`:
    *   `id`: UUID
    *   `code`: ValueObject (e.g. `CTRL-IAM-01`)
    *   `title`: string
    *   `description`: string
    *   `frameworkMappings`: Array of `FrameworkMapping`
    *   `implementationStatus`: `NOT_STARTED` | `IN_PROGRESS` | `IMPLEMENTED` | `EXEMPT`
    *   `testFrequency`: `CONTINUOUS` | `WEEKLY` | `MONTHLY` | `ANNUAL`
    *   `assignedOwner`: `UserReference`

### 3.3 Risk Assessment Model
*   **Formula:**
    $$\text{Inherent Score} = \text{Likelihood}\,(1..5) \times \text{Impact}\,(1..5) \in [1..25]$$
    $$\text{Mitigation Factor} = \sum (\text{Control Effectiveness} \times \text{Control Weight}) \in [0.0..1.0]$$
    $$\text{Residual Score} = \text{round}(\text{Inherent Score} \times (1 - \text{Mitigation Factor}))$$
*   **Heatmap Classification:**
    *   `Low` (1–4, Green)
    *   `Medium` (5–9, Yellow)
    *   `High` (10–16, Orange)
    *   `Critical` (17–25, Red)

### 3.4 Cryptographic Audit Ledger
*   Every critical operation (status changes, risk recalculation, evidence upload) appends a cryptographically verified record:
    $$\text{Hash}_n = \text{SHA-256}\left(\text{Seq}_n + \text{Timestamp}_n + \text{Actor}_n + \text{Payload}_n + \text{Hash}_{n-1}\right)$$
*   Any modification of past history invalidates all subsequent hashes, providing instant evidence of tampering.

---

## 4. Frontend & UI/UX Architecture

### 4.1 Design Philosophy (Impeccable Standards)
*   **Avoid Generic AI Slop:** No gratuitous drop shadows, oversized pill buttons, or arbitrary pastel cards.
*   **Information Density:** Tailored for compliance analysts and auditors who need to view complex tables, heatmaps, and evidence trees without excessive pagination.
*   **Typographic Scale:** Clean, legible sans-serif hierarchy (Geist / Inter / JetBrains Mono for codes and cryptographic hashes).
*   **Accessibility:** WCAG 2.1 AA compliant, complete keyboard shortcuts, high-contrast dark and light modes.

### 4.2 State Separation Strategy
*   **Server State (TanStack Query):**
    *   `useFrameworks()`, `useControls()`, `useRiskRegister()`, `useAuditLedger()`.
    *   Optimistic mutations for immediate UI responsiveness.
*   **Client State (Zustand):**
    *   `useUIStore`: Active sidebar state, selected compliance framework tab, risk matrix zoom level.
    *   `useFilterStore`: Active severity filters, owner filters, search keyword tokens.
*   **URL State:**
    *   Deep-linkable filter parameters (`?framework=iso27001&status=failed&search=mfa`).

### 4.3 Component Composition & Animation
*   **Compound Components:** Modular `<RiskMatrix>`, `<ControlGrid>`, `<EvidenceDrawer>`.
*   **Transitions:** Smooth transitions with `@vercel/react-view-transitions` between summary cards and drill-down audit views.

---

## 5. Technology Stack Summary

| Layer / Concern | Technology Selection | Rationale |
| :--- | :--- | :--- |
| **Language** | TypeScript 5.5+ (Strict Mode) | Zero `any`, complete compile-time type safety |
| **Framework** | Next.js / Vite + React 19 | Fast HMR, modern server/client boundaries |
| **Styling** | Tailwind CSS v4 | Utility-first, zero runtime CSS overhead |
| **Components** | Shadcn UI + Radix/Base UI | Accessible, headless, fully customizable slots |
| **Server State** | TanStack Query v5 | Robust cache invalidation, optimistic updates |
| **Client State** | Zustand v5 | Minimal footprint, atomic slices, zero re-render overhead |
| **Animation** | `@vercel/react-view-transitions` | Native View Transitions API support |
| **Icons** | Lucide React | Clean, consistent enterprise icon system |
| **Cryptography** | Web Crypto API (SHA-256) | Built-in browser and Node native cryptographic security |
| **Testing** | Vitest + React Testing Library | Blazing fast TDD execution |
| **Health Auditing**| Million.co React Doctor | Continuous component and bundle health tracking |

---

## 6. Implementation Roadmap

1.  **Phase 1: Multi-AI Scaffolding & Shared Infrastructure** *(Completed)*
    *   Universal `.agents/` repository layout. All four AIs discover skills natively from `.agents/skills/`. Thin bridges: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursorrules`.
    *   Installed 52 agent skills (Superpowers, Claude-Mem, React Doctor including `find-similar-functions`, Shadcn, Impeccable, TanStack, Zustand, View Transitions, Composition Patterns).
    *   Scaffolded `AGENTS.md`, `GEMINI.md`, and `DESIGN.md`.
2.  **Phase 2: Core Domain Model & TDD Test Engine**
    *   Implement Framework, Control, Risk, Evidence, and Audit entities with 100% test coverage.
3.  **Phase 3: Cryptographic Audit Engine & Storage Adapters**
    *   WebCrypto SHA-256 hash chaining and tamper-detection algorithm.
4.  **Phase 4: Design System & Component Library**
    *   Shadcn UI setup with custom GRC design tokens, dark mode, and high-density layouts.
5.  **Phase 5: Interactive GRC Modules**
    *   Framework Explorer, Risk Heatmap Matrix, Control Compliance Tracker, Audit Timeline.
6.  **Phase 6: Verification, Performance Polish & Portfolio Packaging**
    *   React Doctor audit score $\ge 90/100$, end-to-end verification, demo data presets.
