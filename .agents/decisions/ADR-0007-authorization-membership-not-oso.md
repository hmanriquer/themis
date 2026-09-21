# ADR-0007: Authorization — Company Membership + Process Assignment (Not Oso)

## Status
Accepted (amended 2026-09-21: identity provider is Better Auth, ADR-0008)

## Date
2026-09-21

## Context
The operational process workflow needs four facts:

1. A person may work in more than one company (six historic liables span GSA and GSE).
2. **Liable** is a duty on a process, not a global job title.
3. Sub-liables and other authorized viewers can **see** a process and its timeline but **cannot approve** controls.
4. Security rule 05 already requires RBAC + ABAC at the use-case boundary, not only in `iris`.

Oso Polar / Oso Cloud, OpenFGA, and SpiceDB would add a second policy language and runtime. The relationship graph is shallow: three tenants, ~62 people, one liable per process.

## Decision
**Do not adopt Oso, Oso Cloud, OpenFGA, or SpiceDB for v1.** Authorization is application-owned inside `olympus`.

### Identity vs authorization
- **`User`:** identity only (`email`, `fullName`, `isActive`). No `User.role = LIABLE`. No single `User.companyId`.
- **Authentication** is **Better Auth** (ADR-0008). This ADR covers authorization only.

### Authorization tables
1. **`CompanyMembership`** `(userId, companyId, role)`
   - `ADMIN` | `RISK_MANAGER` | `MEMBER`
   - Unique `(userId, companyId)`
2. **`ProcessAssignment`** `(processId, userId, kind)`
   - `LIABLE` | `SUB_LIABLE` | `STAKEHOLDER` | `AUDITOR`
   - Unique `(processId, userId)`
   - **Exactly one `LIABLE` per process** (unique partial index on `processId` where `kind = LIABLE`)

CASL is optional as an Ability builder **behind** the same policy service. Postgres RLS is phase 2 defense-in-depth after membership exists; it does not replace use-case checks.

### Permission matrix (enforced in each use case)

| Action | Company admin | Risk manager | Liable (assigned) | Sub-liable / viewer |
| :--- | :--- | :--- | :--- | :--- |
| Create process in company | Yes | Yes | No | No |
| Edit risks / controls (`IN_REVIEW`) | Yes | Yes | No | No |
| Submit for approval | Yes | Yes | No | No |
| Approve / request changes | Override only | No | Yes | **No** |
| Grant / revoke viewers | Yes | Yes | Yes | No |
| Migrate / change name or liable | Yes | Yes | No | No |
| Read process + timeline | Yes | Yes (own company) | Yes | Yes (granted) |
| Losable / non-losable dashboard | Yes | Yes | No | No |

A person may be risk manager in GSE and liable on a PR process. Evaluate membership for the process’s `companyId` and assignment for that `processId` together.

Revisit ReBAC (Oso / OpenFGA) only if process trees, delegation chains, or cross-tenant sharing appear.

## Consequences
### Positive
- Matches historic multi-company people and the approve-vs-view split.
- All four AIs can unit-test a policy function without a sidecar.
- Aligns with Nest Guards (rule 06) and least privilege (rule 05).

### Negative
- Permission changes require a code/review cycle instead of a Polar file.
- Passwords stay in Better Auth (ADR-0008), not on a hand-rolled `User.password` column.

### Neutral
- `ProcessViewer` in the draft Prisma dump is superseded by `ProcessAssignment`.
- `UserRole.LIABLE` in that dump is invalid.
