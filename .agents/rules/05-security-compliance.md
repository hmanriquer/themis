# Security & Compliance Standards (GRC Specification)

Because Themis is an enterprise-grade Governance, Risk, and Compliance platform, the code and architecture must embody the very standards it audits.

---

## 1. Security Architecture Principles

*   **Zero Trust & Principle of Least Privilege:**
    *   Every user, service, and API client has the minimum necessary permissions to perform its function.
    *   Role-Based Access Control (RBAC) and Attribute-Based Access Control (ABAC) must be enforced at the Application Use Case boundary, not merely in UI views.
*   **Immutability of Audit Trails:**
    *   Audit logs must be append-only. No `UPDATE` or `DELETE` operations are ever permitted on audit entities.
    *   Each audit record must incorporate cryptographic chaining (SHA-256 / HMAC) referencing the hash of the preceding entry, producing a tamper-evident audit ledger.
*   **Data Integrity & Non-Repudiation:**
    *   Evidence artifacts must be hashed (SHA-256) upon ingestion. Any subsequent change invalidates compliance certification.
    *   Actions taken by users or automated monitors must record actor identity, timestamp, IP/origin metadata, and state diffs.

---

## 2. Regulatory Alignment

*   **SOC 2 Type II:** Trust Services Criteria (Security, Availability, Processing Integrity, Confidentiality, Privacy).
*   **ISO/IEC 27001:2022:** Information security management system controls, risk treatment plans, and continuous monitoring.
*   **NIST CSF 2.0:** Govern, Identify, Protect, Detect, Respond, Recover functions.
*   **GDPR / Privacy by Design:** Data minimization, purpose limitation, right to be forgotten (with cryptographic tombstoning where legal hold applies).

---

## 3. Code Security & Secret Management

*   **Zero Hardcoded Credentials:** Never store tokens, API keys, private keys, or passwords in Git or client bundles. Validate environment variables with a Zod schema at startup in both `iris` and `olympus`. Feature code must not read untyped `process.env`.
*   **Error Envelope:** `olympus` serializes failures as the `@themis/nomos` HTTP error schema (derived from `ThemisError`). `iris` parses that envelope in the `ky` client and surfaces it through TanStack Query error state. Do not invent a second error shape.
*   **Input Sanitization & Output Encoding:** Sanitize all markdown inputs and rich-text evidence descriptions to prevent Cross-Site Scripting (XSS).
*   **Strict Typing on Compliance Calculations:** No floating-point rounding quirks on risk formulas; use well-defined integer scales ($1..5$, $1..100$) or decimal value objects. Those scales are named constants in `nomos` and/or `olympus` domain — never magic numbers in UI.
