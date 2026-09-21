# GRC Domain Overview: Governance, Risk, and Compliance

This knowledge document provides essential context for all 4 AI agents to accurately reason about GRC concepts when building Themis.

---

## 1. The Three Pillars of GRC

### Governance
*   **Definition:** The structured framework of authority, accountability, and policies that steer the organization toward its business and ethical objectives.
*   **Key Concepts:**
    *   *Policies:* Formal statements of intent and organizational rules (e.g. Information Security Policy, Access Control Policy).
    *   *Roles & Accountability:* CISO, Compliance Officer, Risk Owner, Control Assessor.
    *   *Oversight & Reporting:* Executive dashboards, board-level metric rollups, audit readiness summaries.

### Risk Management
*   **Definition:** The systematic identification, evaluation, prioritization, and mitigation of operational, cyber, financial, and regulatory threats.
*   **Calculation Mechanics (operational v1 — ADR-0006):** qualitative 5×5 heatmap of frequency × severity. Canonical cell *poco frecuente × bajo* = Insignificante. Process grade is the rounded mean of member risk grades. See `.agents/knowledge/operational-process-workflow.md`.
*   **Calculation Mechanics (framework residual — later Dike):**
    *   $\text{Inherent Risk} = \text{Likelihood} \times \text{Impact}$ (where Likelihood $\in [1..5]$, Impact $\in [1..5]$, producing a score $\in [1..25]$).
    *   $\text{Control Mitigation Factor} \in [0.0..1.0]$ based on control maturity and testing status.
    *   $\text{Residual Risk} = \text{Inherent Risk} \times (1 - \text{Mitigation Factor})$.
    *   *Treatment Strategies:* Mitigate (implement controls), Accept (signoff within risk appetite), Transfer (insurance, third party), Avoid (terminate activity).

### Compliance
*   **Definition:** Adhering to laws, industry regulations, security standards, and contractual obligations.
*   **Key Concepts:**
    *   *Frameworks:* Standardized sets of controls (ISO 27001, SOC 2, NIST CSF).
    *   *Control Mapping:* Cross-referencing one internal control to multiple regulatory requirements (e.g. multi-factor authentication satisfies SOC 2 CC6.1, ISO 27001 A.9.4.2, and NIST AC-7).
    *   *Evidence Collection:* Proof that a control operates effectively (e.g., config screenshots, CI/CD pipeline enforcement, vulnerability scan results).
    *   *Audit Cycles:* Periodic evaluations with findings, gap analysis, and remediation tracking.
