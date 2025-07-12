Documentation of My reasoning

Designing the data architecture
We have 4 main options here
1. architecture of a data warehouse
2. architecture of a data lake
3. architecture of a data warehouse and a data lake, also called a lakehouse
4. architecture of a data mesh.

I choose option 1. architecture of a data warehouse
why? because of the nature of our data. it is structured and we are prioritizing analytics and reporting
now, how to build it?
4 methods present themselves to us:

Inmon:
kimball
data vault
medallion way

## Visualizing the Four Data-Warehousing Methodologies

### 1. Inmon – Corporate Information Factory
```mermaid
flowchart LR
    A[Source Systems] --> B[Staging Area]
    B --> C[Enterprise Data Warehouse (3NF)]
    C --> D[Data Marts (Dimensional)]
    D --> E[BI / Analytics]
```

### 2. Kimball – Dimensional Bus Architecture
```mermaid
flowchart LR
    A[Source Systems] --> B[Staging Area]
    B --> C[Dimensional Data Warehouse (Star / Snowflake)]
    C --> D[BI / Analytics]
```

### 3. Data Vault 2.0
```mermaid
flowchart LR
    A[Source Systems] --> B[Staging Area]
    B --> C[Raw Vault (Hubs + Links + Sats)]
    C --> D[Business Vault]
    D --> E[Data Marts]
    E --> F[BI / Analytics]
```

### 4. Medallion (Bronze / Silver / Gold)
```mermaid
flowchart LR
    A[Source Systems] --> B[Bronze Layer (Raw Ingest)]
    B --> C[Silver Layer (Cleansed & Enriched)]
    C --> D[Gold Layer (Curated / Aggregated)]
    D --> E[BI / Analytics]
```

## Why We Opt for the Medallion Architecture
The Medallion pattern aligns best with our context for the following reasons:
1. **Schema Evolution & Flexibility** – Keeping raw data in the Bronze layer preserves full fidelity, letting us replay or re-process data as business logic changes without re-ingesting.
2. **Progressive Quality Gates** – Each layer (Bronze → Silver → Gold) adds specific, testable transformations, giving clear data SLAs and easier debugging.
3. **Incremental & Streaming Friendly** – Supports both batch and streaming ingestion, which is valuable if real-time feeds are introduced later.
4. **Cost-Effective Storage** – Cheap object storage can house Bronze data, while optimized formats (Parquet/Delta) serve analytic queries in Gold.
5. **Developer Productivity** – The layered approach maps naturally to modern lakehouse engines (e.g., Databricks Delta) and integrates smoothly with our SQL-centric analytics workflow.

Given these benefits—especially the combination of raw data retention and curated, performant tables for reporting—the Medallion architecture offers the right balance between governance, agility, and analytic performance for our structured data warehouse project.