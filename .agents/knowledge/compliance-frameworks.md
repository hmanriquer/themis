# Compliance Frameworks & Control Taxonomies

This document outlines the major compliance frameworks supported in Themis and their cross-mapping structure.

---

## 1. Supported Frameworks

### 1. ISO/IEC 27001:2022
*   **Structure:** 4 Themes, 93 Controls (Annex A)
    *   *Organizational Controls* (Clause 5: 37 controls)
    *   *People Controls* (Clause 6: 8 controls)
    *   *Physical Controls* (Clause 7: 14 controls)
    *   *Technological Controls* (Clause 8: 34 controls)
*   **Key Themes:** Threat intelligence, information security in cloud services, ICT readiness for business continuity, physical security monitoring.

### 2. SOC 2 Type II (AICPA Trust Services Criteria)
*   **Categories:**
    *   `CC`: Common Criteria (Security) - CC1.0 through CC9.0
    *   `A`: Availability
    *   `C`: Confidentiality
    *   `PI`: Processing Integrity
    *   `P`: Privacy
*   **Core Points of Focus:** Logical and physical access controls, change management, system operations, risk mitigation.

### 3. NIST CSF 2.0 (National Institute of Standards and Technology)
*   **Functions:**
    *   `GV`: Govern (Organizational context, risk management strategy, cybersecurity supply chain)
    *   `ID`: Identify (Asset management, risk assessment)
    *   `PR`: Protect (Identity management, data security, platform security)
    *   `DE`: Detect (Continuous monitoring, adverse event analysis)
    *   `RS`: Respond (Incident management, mitigation)
    *   `RC`: Recover (Incident recovery plan execution)

### 4. HIPAA Security Rule (45 CFR Part 164)
*   **Safeguards:**
    *   *Administrative Safeguards* (§ 164.308): Security management process, workforce training.
    *   *Physical Safeguards* (§ 164.310): Facility access, workstation security.
    *   *Technical Safeguards* (§ 164.312): Access control, audit controls, integrity, transmission security.

### 5. GDPR (General Data Protection Regulation)
*   **Key Articles:**
    *   *Article 25:* Data protection by design and by default.
    *   *Article 30:* Records of processing activities (ROPA).
    *   *Article 32:* Security of processing (encryption, resilience).
    *   *Article 33 & 34:* Data breach notification (72-hour window).

---

## 2. Common Control Mapping Matrix

| Internal Control Code | Description | ISO 27001:2022 | SOC 2 | NIST CSF 2.0 | HIPAA |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `CTRL-IAM-01` | Multi-Factor Authentication (MFA) | A.8.5 | CC6.1 | PR.AA-01 | §164.312(a)(2)(iv) |
| `CTRL-LOG-01` | Centralized Tamper-Evident Audit Logging | A.8.15 | CC7.2 | DE.CM-01 | §164.312(b) |
| `CTRL-CRY-01` | Encryption at Rest (AES-256) | A.8.24 | CC6.1 | PR.DS-01 | §164.312(a)(2)(iv) |
| `CTRL-CRY-02` | Encryption in Transit (TLS 1.3) | A.8.20 | CC6.6 | PR.DS-02 | §164.312(e)(1) |
| `CTRL-VUL-01` | Automated Vulnerability Scanning & Patching | A.8.8 | CC7.1 | PR.IP-03 | §164.308(a)(1)(ii)(A) |
| `CTRL-BCP-01` | Backup Verification & Disaster Recovery | A.8.13, A.8.14 | A1.2 | RC.RP-01 | §164.308(a)(7)(ii)(A) |
