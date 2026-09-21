# ADR-0006: Operational Process-Risk Bounded Context (PostgreSQL + Prisma)

## Status
Accepted

## Date
2026-09-21

## Context
Themis must digitize the operational-risk workflow used across three companies (General de Salud, General de Seguros, Reaseguradora Patria). The source of truth for that workflow is `historic(in).csv` (1,352 assessments) plus yearly RCOP severity bands in `SEVERIDADES X COMPAÑIA - 2022.txt`.

`DESIGN.md` also describes ISO/SOC 2 **framework** controls and a residual-risk formula (likelihood × impact ∈ [1..25]). Those are a later Dike concern. Mixing them with operational process assessments would produce two incompatible `Control` and `Risk` models.

Persistence was already chosen: PostgreSQL with Prisma on NestJS (`olympus`).

## Decision
1. **Bounded context (v1):** `prometheus` owns the **operational process-risk lifecycle**. Dike (`Framework`, framework `ControlRequirement`) and Mnemosyne (`Evidence`) stay out of this schema until a later phase. English GRC names stay (`Process`, `Risk`, `Control`); they are not framework Annex-A controls.
2. **Persistence:** PostgreSQL. Prisma ORM registered as a Nest provider in `olympus` `infrastructure/`. Domain folders remain Prisma-free (ports only). Schema lives with Olympus; `nomos` holds DTOs, not the Prisma client.
3. **Process is the aggregate root.** A process has company, area, exactly one liable (via `ProcessAssignment`), `assessedAt`, `expiresAt`, `familyId` (stable business identity across versions), `version`, and `migratedFromId`. Physical migration **inserts a new row** of the same family; it is not a sibling process with a new identity.
4. **Lifecycle statuses and guards:**

   | From | To | Guard |
   | :--- | :--- | :--- |
   | (start) | `DRAFT` | Company, area, liable, name present; notify liable (Hermes) |
   | `DRAFT` | `IN_REVIEW` | Kickoff meeting recorded |
   | `IN_REVIEW` | `PENDING_APPROVAL` | ≥1 risk; every risk has ≥1 control |
   | `PENDING_APPROVAL` | `IN_REVIEW` | Any control → `CHANGES_REQUESTED` |
   | `PENDING_APPROVAL` | `APPROVED` | Control count ≥ 1 and 100% `APPROVED`; compute `overallGrade`; set `approvedAt` |
   | `APPROVED` | `MIGRATED` | `MigrateProcess` succeeds |
   | `APPROVED` | `EXPIRED` | `expiresAt < now` and not migrated |
   | `APPROVED` / `MIGRATED` / `EXPIRED` | writes | Forbidden except viewer grants and append-only logs |

5. **Heatmap:** New assessments derive `Risk.grade` from `(frequency, severity)`. Canonical cell **poco frecuente × bajo → Insignificante**. Store grade on the row so historic outliers can be imported unchanged. Do not overwrite seeded grades.
6. **Process grade:** Arithmetic mean of member risk grades, then **banker's rounding** (round half to even) before mapping back to `RiskGrade` (ADR-0009). Empty-risk process cannot close.
7. **Migration copy scope:** `FULL` | `ONLY_RISKS` | `ONLY_CONTROLS` | `METADATA_ONLY`. Copied controls reset to `PENDING_APPROVAL`. Old process becomes `MIGRATED` and stays readable.
8. **Taxonomy:** Adjacency list of unbounded depth. A risk points at a **leaf** (node with no children), not `level === 3`. Historic paths range from depth 1 to 6.
9. **Two logs:**
   - `ProcessTimelineEvent` — UI timeline on the process page.
   - Astraea `AuditEvent` — append-only SHA-256 hash chain (ADR-0002, rule 05). Timeline is not the ledger.
10. **Dashboard grain:** `assessedAt` month + `companyId` + `isLosable`. v1 is **counts by severity**, not invented MXN midpoints. RCOP bands stay on `CompanyCapitalRequirement` for later exposure math.
11. **Meetings and notifications:** First-class `Meeting` (heldAt, attendees, notes) and a Hermes outbox. Do not model either as a timeline enum only.

Canonical spec: `docs/superpowers/specs/2026-09-21-database-schema-grc-core-design.md`. Workflow: `.agents/knowledge/operational-process-workflow.md`. Authorization: ADR-0007.

## Consequences
### Positive
- One operational model that seed, domain, and UI can share.
- Prisma stays an infrastructure detail; Codex can TDD the state machine in pure TypeScript.
- Framework GRC and operational GRC no longer collide on `Control`.

### Negative
- Two notions of “control” exist in the product vocabulary; UI copy and module folders must keep them apart (`/risks` vs `/compliance`).
- Historic heatmap outliers remain visible after seed; they are data, not a second formula.

### Neutral
- Prisma schema in the design spec is illustrative. OpenCode owns `schema.prisma`; when they conflict, this ADR and the state-machine table win.
