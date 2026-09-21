# Multi-AI Team Roles & Responsibility Matrix

| Capability / Task Area | Primary AI Lead | Secondary AI | Reviewer / Verifier |
| :--- | :--- | :--- | :--- |
| **System Architecture & ADRs** | Antigravity | OpenCode | Human Lead |
| **Domain Model & Entities** | Codex | Antigravity | Antigravity |
| **Application Use Cases** | Codex | Cursor | Antigravity |
| **UI Components & Shadcn** | Cursor | Codex | Human Lead / Antigravity |
| **State Management (Zustand/Query)** | Cursor | Codex | Antigravity |
| **Infrastructure Adapters** | OpenCode | Codex | Antigravity |
| **Terminal & Tooling Automation** | OpenCode | Antigravity | OpenCode |
| **Testing & TDD Verification** | Codex | OpenCode | Antigravity |
| **Aesthetic Polish & Accessibility** | Cursor | Human Lead | Impeccable / React Doctor |
| **Security & GRC Compliance Audit** | Antigravity | Codex | Human Lead |

---

## Escalation Path
If any AI encounters ambiguity, conflicting requirements, or architectural trade-offs:
1.  Check `.agents/decisions/` for existing ADR precedents.
2.  If unaddressed, Antigravity drafts an ADR proposal in `.agents/decisions/`.
3.  Notify the human developer before proceeding with high-impact breaking changes.
