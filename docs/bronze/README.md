# Bronze Layer Architecture

The Bronze layer stores raw copies of the CSV files exactly as received. It serves as the persistent staging area and system of record.

```mermaid
flowchart TD
    A[CRM CSV files] -->|BULK INSERT| B((bronze.crm_* tables))
    C[ERP CSV files] -->|BULK INSERT| D((bronze.erp_* tables))
    B --> E[bronze schema]
    D --> E
    subgraph Ingestion Procedure
        F[load_bronze]
    end
    F --> B
    F --> D
```

The `load_bronze` stored procedure truncates each target table and bulk loads all files from the `datasets` folder, printing a preview and timing metrics.
