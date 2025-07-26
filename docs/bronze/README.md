# Bronze Layer Architecture

The Bronze layer stores raw copies of the CSV files exactly as received. It serves as the persistent staging area and system of record.

```mermaid
graph TD
    subgraph Source[Source Files]
        %% CRM Files
        C1[cust_info.csv<br>id, key, name, status]
        C2[prd_info.csv<br>id, key, name, cost]
        C3[sales_details.csv<br>order, product, customer]
        
        %% ERP Files
        E1[CUST_AZ12.csv<br>CID, BDATE, GEN]
        E2[LOC_A101.csv<br>CID, CNTRY]
    end

    subgraph Process[ETL Process]
        P0[load_bronze Procedure]
        P1[BULK INSERT CRM]
        P2[BULK INSERT ERP]
        V[Validate Row Counts]
    end

    subgraph Target[Bronze Layer]
        B1[bronze.crm_cust_info<br>Raw Customer Data]
        B2[bronze.crm_prd_info<br>Raw Product Data]
        B3[bronze.crm_sales_details<br>Raw Sales Data]
        B4[bronze.erp_cust_az12<br>Raw ERP Customer]
        B5[bronze.erp_loc_a101<br>Raw Location Data]
    end

    %% Source to Process
    C1 & C2 & C3 --> P1
    E1 & E2 --> P2

    %% Process Flow
    P0 --> P1 & P2
    P1 & P2 --> V

    %% Process to Target
    P1 --> B1 & B2 & B3
    P2 --> B4 & B5
    
    %% ERP Source Files with Details
    E1[CUST_AZ12.csv<br>CID, BDATE, GEN] --> P2[BULK INSERT<br>ERP Data]
    E2[LOC_A101.csv<br>CID, CNTRY] --> P2
    
    %% Bronze Tables with Descriptions
    P1 --> B1[bronze.crm_cust_info<br>Raw Customer Data]
    P1 --> B2[bronze.crm_prd_info<br>Raw Product Data]
    P1 --> B3[bronze.crm_sales_details<br>Raw Sales Data]
    P2 --> B4[bronze.erp_cust_az12<br>Raw ERP Customer]
    P2 --> B5[bronze.erp_loc_a101<br>Raw Location Data]
    
    %% Process Control
    P0[load_bronze Procedure<br>Orchestrates Load] --> P1
    P0 --> P2
    end

    subgraph Bronze Schema
        direction LR
        C1[(bronze.crm_cust_info)]
        C2[(bronze.crm_prd_info)]
        C3[(bronze.crm_sales_details)]
        style C1 fill:#f7e8d0
        style C2 fill:#f7e8d0
        style C3 fill:#f7e8d0

        D1[(bronze.erp_cust_az12)]
        D2[(bronze.erp_loc_a101)]
        D3[(bronze.erp_px_cat_g1v2)]
        style D1 fill:#f0d0f7
        style D2 fill:#f0d0f7
        style D3 fill:#f0d0f7
    end

    subgraph Ingestion Process
        direction TB
        E[load_bronze stored procedure]
        F[Bulk Insert Operations]
        G[Row Count Validation]
        H[Load Timestamps]
        style E fill:#f9f9f9,stroke:#666
        style F fill:#f9f9f9,stroke:#666
        style G fill:#f9f9f9,stroke:#666
        style H fill:#f9f9f9,stroke:#666
        E --> F
        F --> G
        G --> H
    end

    %% Source to Bronze connections
    A1 --> F
    A2 --> F
    A3 --> F
    B1 --> F
    B2 --> F
    B3 --> F

    %% Bronze tables connections
    F --> C1
    F --> C2
    F --> C3
    F --> D1
    F --> D2
    F --> D3

    classDef default fill:#fff,stroke:#333,stroke-width:2px;
    classDef process fill:#f9f9f9,stroke:#666,stroke-width:2px;
```

The `load_bronze` stored procedure truncates each target table and bulk loads all files from the `datasets` folder, printing a preview and timing metrics.
