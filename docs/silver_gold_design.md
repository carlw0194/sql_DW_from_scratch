# Silver & Gold Layer Design

This note summarises the reasoning behind the newly added SQL scripts for the
Silver and Gold layers. The project initially focused on the Bronze layer –
loading raw extracts exactly as received. The next steps introduce additional
transformations so that downstream analytics have a consistent and easy to query
schema.

## Silver Layer

The Silver layer serves as a **cleansed and conformed** copy of the raw data.
Key considerations:

- **Minimal transformations** – only trim whitespace, convert obvious data types
  and join related ERP tables. Heavy business logic is left for the Gold layer.
- **Source-aligned names** – tables retain the `<system>_<entity>` pattern to
  preserve lineage with the operational systems.
- **Idempotent loads** – `p_load_silver.sql` truncates the target tables before
  inserting, relying on the Bronze layer as the system of record.
- **Extensibility** – the procedure is deliberately simple; real projects would
  incorporate de-duplication rules, CDC logic, and error handling.

## Gold Layer

The Gold layer exposes analytics-ready structures:

- **Dimensions and facts** – `dim_customers`, `dim_products` and
  `fact_sales` follow the business-centric naming conventions from
  `docs/naming_conventions.md`.
- **Surrogate keys** – identity columns provide stable keys for BI tools and
  star-schema joins.
- **Derived attributes** – customer gender and country are enriched using CRM and
  ERP data where available.
- **Lightweight example** – `p_load_gold.sql` demonstrates simple key lookups
  and inserts. Real implementations would handle slowly changing dimensions,
  incremental loads and audit logging.

These scripts establish a foundation for a traditional Medallion-style
warehouse. They are intentionally concise so they can be adapted and extended as
the project evolves.
