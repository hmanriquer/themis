# Themis System Architecture Overview

Themis is an enterprise-grade Governance, Risk, and Compliance (GRC) platform engineered for portfolio demonstration. It models how high-assurance organizations continuously evaluate compliance against multiple standards, quantify and mitigate risk, collect tamper-evident evidence, and maintain cryptographically auditable operational logs.

---

## 1. High-Level System Architecture

```
                                  +---------------------------------------+
                                  |       React 19 Presentation Layer     |
                                  |   (Shadcn UI + View Transitions)      |
                                  +-------------------+-------------------+
                                                      |
                                                      v
                                  +---------------------------------------+
                                  |     State & Data Management Layer     |
                                  |  - Zustand (Client / Filter / UI)     |
                                  |  - TanStack Query (Server Caches)     |
                                  +-------------------+-------------------+
                                                      |
                                                      v
                                  +---------------------------------------+
                                  |       Application Use Cases Layer     |
                                  |  - AssessRiskUseCase                  |
                                  |  - VerifyControlComplianceUseCase     |
                                  |  - RecordTamperProofAuditEventUseCase |
                                  |  - GenerateComplianceScorecardUseCase |
                                  +-------------------+-------------------+
                                                      |
                                                      v
+---------------------------------+---------------------------------------+---------------------------------+
|                                 |         Pure Domain Model Layer       |                                 |
|  - Framework Aggregate Root     |  - Risk Registry & Scoring Matrix     |  - Tamper-Evident Audit Ledger  |
|  - Control Specification Entity |  - Evidence Value Objects             |  - Cryptographic Hash Chains    |
+---------------------------------+-------------------+-------------------+---------------------------------+
                                                      |
                                                      v
                                  +---------------------------------------+
                                  |      Infrastructure Adapters Layer    |
                                  |  - WebCrypto SHA-256 Signer           |
                                  |  - IndexedDB / LocalStorage Adapter   |
                                  |  - Mock Compliance Evidence Ingestor  |
                                  |  - Audit Export (JSON/CSV/PDF)        |
                                  +---------------------------------------+
```

---

## 2. Core Domain Models

1.  **Compliance Framework:**
    *   *Examples:* ISO 27001:2022, SOC 2 Type II, NIST CSF 2.0, HIPAA Security Rule, GDPR.
    *   *Attributes:* ID, standard code, title, version, domains/sections, control collection.
2.  **Control:**
    *   *Attributes:* Code (e.g. `AC-1`, `A.5.1`, `CC6.1`), title, description, category, implementation status (`Implemented`, `Partially Implemented`, `Not Implemented`, `Not Applicable`), criticality (`Low`, `Medium`, `High`, `Critical`), assigned owner.
3.  **Risk:**
    *   *Attributes:* ID, title, threat description, category, inherent impact ($1..5$), inherent likelihood ($1..5$), inherent score, mapped controls, residual impact, residual likelihood, residual score, status (`Open`, `Mitigated`, `Accepted`, `Transferred`).
4.  **Evidence:**
    *   *Attributes:* ID, controlId, title, storageUri, mimeType, sha256Checksum, collectionTimestamp, validUntil, verificationStatus (`Valid`, `Expired`, `Tampered`).
5.  **Audit Event:**
    *   *Attributes:* ID, sequenceNumber, timestamp, actorId, actionType, entityType, entityId, payloadDiff, previousHash, recordHash (SHA-256 chain).
