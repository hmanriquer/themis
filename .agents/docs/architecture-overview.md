# Themis System Architecture Overview

Themis is an enterprise-grade Governance, Risk, and Compliance (GRC) platform engineered for portfolio demonstration. It models how high-assurance organizations continuously evaluate compliance against multiple standards, quantify and mitigate risk, collect tamper-evident evidence, and maintain cryptographically auditable operational logs.

---

## 1. High-Level System Architecture

```
                                  +---------------------------------------+
                                  |  iris (TanStack Start presentation)   |
                                  |  dumb routes · smart features · UI    |
                                  +-------------------+-------------------+
                                                      |
                                                      | ky + TanStack Query
                                                      | @themis/nomos DTOs
                                                      v
                                  +---------------------------------------+
                                  |  olympus (NestJS)                     |
                                  |  controllers → services → domain      |
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
                                  |      Infrastructure (Nest providers)  |
                                  |  - SHA-256 signer · persistence       |
                                  |  - Evidence ingest · audit export     |
                                  +---------------------------------------+
```

---

## 2. Core Domain Models

v1 is operational process-risk (ADR-0006). Framework catalogs are a later Dike phase.

1.  **Process (aggregate root):**
    *   Company, area, `familyId` / version / `migratedFromId`, `assessedAt`, `expiresAt`, status machine (`DRAFT` → `IN_REVIEW` → `PENDING_APPROVAL` → `APPROVED` → `MIGRATED` | `EXPIRED`).
    *   Exactly one liable via `ProcessAssignment`. Sub-liables may read, not approve (ADR-0007).
2.  **Operational Risk:**
    *   Frequency, severity, stored grade (5×5 heatmap), `isLosable`, taxonomy leaf (unbounded depth).
3.  **Operational Control:**
    *   Frequency, approval status, M:N mitigations, change-request thread with mandatory liable comment.
4.  **CompanyCapitalRequirement:**
    *   Yearly RCOP and absolute MXN severity bands per company.
5.  **Compliance Framework** *(later — Dike):*
    *   ISO 27001, SOC 2, NIST CSF, HIPAA, GDPR control catalogs. Distinct from operational controls.
6.  **Evidence** *(later — Mnemosyne):*
    *   ID, controlId, title, storageUri, mimeType, sha256Checksum, collectionTimestamp, validUntil, verificationStatus.
7.  **Audit Event (Astraea):**
    *   ID, sequenceNumber, timestamp, actorId, actionType, entityType, entityId, payloadDiff, previousHash, recordHash (SHA-256 chain). Separate from the process UI timeline.
