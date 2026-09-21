# ADR-0009: Spanish Product Surface, Entity Codes, Banker's Rounding

## Status
Accepted

## Date
2026-09-21

## Context
The operational dataset and the three companies are Mexican Spanish. Agents had been writing English GRC copy and English URL paths (`/risks`, `/compliance`). Entity codes in the draft schema were informal (`PROC-PR-2026-001`). Process overall grade used unspecified `round()`.

## Decision

### 1. Language
The **product** is Spanish (`es-MX`).

| Surface | Language |
| :--- | :--- |
| UI copy, buttons, empty/error states, emails, Hermes notifications, user-visible API `message` strings | Spanish |
| URL paths in `iris` | Spanish (`/procesos`, `/riesgos`, `/controles`, `/cumplimiento`, `/auditoria`, `/evidencia`) |
| Historic process/risk/control **content** | Spanish (as imported) |
| TypeScript identifiers, Prisma models, Nest methods, `nomos` schema **keys** | English GRC (`Process`, `Risk`, `Control`, `AssessRisk`) |
| Apps / packages / feature folders | Greek (`iris`, `olympus`, `prometheus`) |

Do not write Spanish class or field names. Do not ship English chrome to users.

Default locale: `es-MX`. No i18n framework in v1 — copy is Spanish literals in `nomos` / feature `constants`, not a translation layer.

### 2. Business codes
Every user-visible entity gets a stable business code, globally unique per prefix:

| Prefix | Entity | Example |
| :--- | :--- | :--- |
| `PROC` | Process | `PROC-001` |
| `CTRL` | Control | `CTRL-001` |
| `RISK` | Risk | `RISK-001` |
| `MEET` | Meeting | `MEET-001` |

Format: `{PREFIX}-{n}` where `n` is a decimal integer **zero-padded to at least 3 digits** (`001` … `999`, then `1000` without a cap). Codes are assigned by Olympus on insert, never by the client. They are immutable after issue.

Company codes stay the historic three-letter codes (`GSA`, `GSE`, `PR`). Area codes are optional labels, not this sequence.

Value objects: `ProcessCode`, `ControlCode`, `RiskCode` in `olympus` domain. Unique in Postgres per table (`processes.code`, `controls.code`, `risks.code`).

Seed: generate sequences in import order from `historic(in).csv` (stable sort by historic `id`).

### 3. Rounding
Process overall grade uses **banker's rounding** (round half to even, IEEE 754 `roundTiesToEven`) on the arithmetic mean of numeric risk grades before mapping back to `RiskGrade`.

Examples: mean `2.5` → `2` (LOW); mean `3.5` → `4` (HIGH). Ties on `.5` go to the even integer. Domain constant name: `BANKERS_ROUNDING` — no magic in callers.

## Consequences
### Positive
- UI matches operators and source data.
- Codes are guessable and unique without embedding year/company.
- Grade math is deterministic at `.5` boundaries.

### Negative
- URL and copy rules in ADR-0004 / rule 00 / rule 03 are superseded for the **user-facing** half; code identifiers stay English.
- v1 has no English locale switch.

### Neutral
- Authorization and persistence ADRs are unchanged.
