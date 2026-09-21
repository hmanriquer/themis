# Operational Process-Risk Workflow

Canonical decisions: [ADR-0006](file:///home/grillo/development/themis/.agents/decisions/ADR-0006-operational-process-risk-postgres.md), [ADR-0007](file:///home/grillo/development/themis/.agents/decisions/ADR-0007-authorization-membership-not-oso.md).
Design spec: `docs/superpowers/specs/2026-09-21-database-schema-grc-core-design.md`.

This is the v1 GRC workflow in `prometheus`. It is **not** the ISO/SOC 2 framework control lifecycle in `dike`.

---

## 1. Happy path

```mermaid
flowchart TD
  create["1. Create process<br/>company, area, liable, assessedAt"]
  notify["2. Hermes notifies liable"]
  meeting["3. Kickoff meeting<br/>liable + risk user"]
  risks["4. Identify N risks<br/>frequency, severity, losable, taxonomy leaf, grade"]
  controls["5. Risk user proposes controls<br/>frequency; map M:N to risks"]
  review["6. Liable reviews each control"]
  changes{"Any control<br/>needs changes?"}
  amend["Liable comment required<br/>risk user amends"]
  close["7. Process APPROVED<br/>overallGrade = mean of risk grades"]
  visible["8. Read-only for liable<br/>and granted sub-liables"]
  later{"Expiry or change?"}
  migrate["9. Migrate: new version of same familyId<br/>copy FULL / ONLY_RISKS / ONLY_CONTROLS / METADATA_ONLY"]
  expire["EXPIRED"]

  create --> notify --> meeting --> risks --> controls --> review --> changes
  changes -->|yes| amend --> controls
  changes -->|no, all approved, count ≥ 1| close --> visible --> later
  later -->|migrate| migrate
  later -->|no renewal| expire
  migrate -->|"old row = MIGRATED"| create
```

Every transition appends a `ProcessTimelineEvent` (UI) and an Astraea `AuditEvent` (hash chain).

---

## 2. State machine

```mermaid
stateDiagram-v2
  [*] --> DRAFT: CreateProcess
  DRAFT --> IN_REVIEW: Meeting recorded
  IN_REVIEW --> PENDING_APPROVAL: ≥1 risk and every risk has ≥1 control
  PENDING_APPROVAL --> IN_REVIEW: Any control CHANGES_REQUESTED
  PENDING_APPROVAL --> APPROVED: All controls APPROVED and count ≥ 1
  APPROVED --> MIGRATED: MigrateProcess
  APPROVED --> EXPIRED: expiresAt passed
  APPROVED --> APPROVED: Viewer grants only
  MIGRATED --> [*]
  EXPIRED --> [*]
```

A process with zero controls must not auto-approve.

---

## 3. Actors

| Actor | Source | Can approve controls? |
| :--- | :--- | :--- |
| Risk manager | `CompanyMembership` | No |
| Liable | `ProcessAssignment.kind = LIABLE` (exactly one per process) | Yes |
| Sub-liable / stakeholder / auditor | `ProcessAssignment` | No — read + timeline only |
| Company admin | `CompanyMembership.role = ADMIN` | Override only |

---

## 4. Migration

Migration is a **new version row** (`version + 1`, same `familyId`, `migratedFromId` set). The operator may change name and/or liable and must choose a copy scope. Copied controls return to `PENDING_APPROVAL`. The source row becomes `MIGRATED` and remains in the lineage log.
