# Gold Layer Architecture

The Gold layer presents curated tables optimised for analytics. Dimensions and fact tables are built from the cleansed Silver layer.

```mermaid
flowchart TD
    A[Silver tables] -->|load_gold| B[dim_customers]
    A -->|load_gold| C[dim_products]
    A -->|load_gold| D[fact_sales]
    B --> E[BI / Reporting]
    C --> E
    D --> E
```

`load_gold` refreshes the dimensions and facts by joining and aggregating the Silver tables. Surrogate keys are generated for efficient star-schema joins.
