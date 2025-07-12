# Source Data Analysis & Ingestion Checklist

_Revision: 2025-07-12_

This document captures the **key questions** and **considerations** a data engineer should resolve before ingesting the current CRM and ERP source files into the Medallion-layer data warehouse.

---

## 1. Source Overview

| System | Files / Tables (sample) | Format | Approx. Rows |
|--------|-------------------------|--------|--------------|
| CRM    | `cust_info.csv`, `prd_info.csv`, `sales_details.csv` | CSV | 3.6 M (sales), ~850 k (customers) |
| ERP    | `CUST_AZ12.csv`, `LOC_A101.csv`, `PX_CAT_G1V2.csv`   | CSV | 500 k–600 k |

Both systems export **comma-separated text files** with a header row. Timestamps appear to be ISO-8601 (e.g., `2025-10-06`).

---

## 2. Fundamental Questions to Ask

### 2.1 Business & Ownership
1. Who owns each source system and can approve interface changes?
2. What is the SLA for data availability and delivery?
3. Which downstream analytics rely on these datasets? (Criticality dictates refresh cadence.)

### 2.2 Technical Characteristics
1. _Delivery method_ — SFTP drop, API, direct DB connection?
2. _Frequency_ — Full nightly dump vs. incremental (CDC)?
3. _File naming conventions & partitioning_ — Are date stamps embedded? Multiple files per day?
4. _Encoding & delimiters_ — UTF-8 vs. ANSI; quotes/escape rules.
5. _Schema stability_ — How often do columns get added/renamed? Is there versioning?

### 2.3 Data Quality & Governance
1. What are the **primary keys**? (e.g., `cst_id`, `cst_key`.)
2. Referential integrity across files (e.g., `sales_details.cst_id` → `cust_info.cst_id`).
3. Expected **nullability** & domain constraints (enums like marital status, gender).
4. Duplicate handling — Are duplicates significant or accidental? How do we dedupe?
5. Historical corrections — Are late-arriving updates possible? How to reconcile?
6. **PII / GDPR** — Fields requiring masking or restricted access?

### 2.4 Volume, Velocity, Variety
1. Anticipated growth rate (rows/day, GB/day)?
2. Peak vs. average delivery times.
3. Compression potential (gzip, parquet) before Bronze storage.

### 2.5 Security & Compliance
1. Network path and encryption in transit (SFTP, HTTPS).
2. Checksums / signatures to verify file integrity.
3. Access control list for ingestion service account.

---

## 3. Ingestion Process Design

| Stage | Key Tasks |
|-------|-----------|
| **Bronze** | • Land raw files exactly as received.<br>• Record metadata (source, load timestamp, checksum, row count).<br>• Store in **immutable** storage (e.g., Azure Data Lake) to enable replay. |
| **Silver**  | • Parse CSV → structured tables.<br>• Enforce data types and basic constraints.<br>• De-duplicate, trim whitespace, standardize date formats.<br>• Capture CDC logic if incremental. |
| **Gold**    | • Aggregate business metrics (e.g., daily sales).<br>• Join CRM & ERP entities.<br>• Apply business definitions and slowly changing dimensions. |

### 3.1 Operational Concerns
* **Idempotency** — Re-ingesting the same file should not create duplicates.
* **Error Handling** — Quarantine bad rows, log errors with context.
* **Monitoring** — Alert on late/missing files, row-count anomalies.
* **Schema Drift** — Automated tests that fail the pipeline when unknown columns appear.

---

## 4. Next Steps
1. Confirm delivery mechanism and schedule with system owners.
2. Catalogue column data types and domain values (sample profiling in Notebook).
3. Configure Bronze landing path naming: `/{system}/{yyyy}/{MM}/{dd}/file.csv`.
4. Draft ingestion DAG (e.g., ADF, Airflow) based on the checklist above.

> _Document owner: Data Engineering Team_
