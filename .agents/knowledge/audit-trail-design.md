# Tamper-Evident Audit Ledger Design

In high-compliance environments, regulatory auditors require absolute non-repudiation. This document details the cryptographic verification protocol implemented in Themis.

---

## 1. Cryptographic Chain Mechanism

Every audit entry forms a link in an append-only cryptographic hash chain modeled on blockchain/Merkle-tree principles:

```
+--------------------------+       +--------------------------+
| Audit Event #1 (Genesis) |       | Audit Event #2           |
| - ID: evt_001            |       | - ID: evt_002            |
| - Timestamp: T1          |       | - Timestamp: T2          |
| - Action: FRAMEWORK_LOAD |       | - Action: CONTROL_UPDATE |
| - PrevHash: 000000...    | ----> | - PrevHash: H(Event #1)  | ----> ...
| - RecordHash: H(Data + 0)|       | - RecordHash: H(Data + H1|
+--------------------------+       +--------------------------+
```

### Formula
$$\text{RecordHash}_n = \text{SHA-256}\left(\text{Sequence}_n \,\|\, \text{Timestamp}_n \,\|\, \text{ActorId}_n \,\|\, \text{Action}_n \,\|\, \text{PayloadCanonicalJson}_n \,\|\, \text{RecordHash}_{n-1}\right)$$

---

## 2. Integrity Verification Algorithm

To verify the audit log's integrity:
1.  Read the genesis record ($n = 1$). Compute its hash using a known zero/genesis seed.
2.  Iterate sequentially over records $n = 2 \dots N$.
3.  Assert that $\text{Record}_{n}.\text{PrevHash} === \text{Record}_{n-1}.\text{RecordHash}$.
4.  Recompute $\text{SHA-256}(\text{Record}_n)$ and assert it matches the stored $\text{RecordHash}_n$.
5.  If any discrepancy occurs, raise a `TamperDetectedError` pointing to the exact sequence number and corrupted byte offset.
