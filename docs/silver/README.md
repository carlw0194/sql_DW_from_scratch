# Silver Layer Architecture

The Silver layer contains cleansed and conformed tables. Data is typed, trimmed and lightly transformed from the raw Bronze layer.

```mermaid
graph TD
    %% Bronze Tables
    B1[bronze.crm_cust_info] --> T1[Clean Customer Data<br>- Trim whitespace<br>- Format dates<br>- Validate status]
    B2[bronze.crm_prd_info] --> T2[Clean Product Data<br>- Standardize names<br>- Convert costs<br>- Validate dates]
    B3[bronze.crm_sales_details] --> T3[Clean Sales Data<br>- Validate amounts<br>- Link references<br>- Check dates]
    
    %% ERP Integration
    B4[bronze.erp_cust_az12] --> T4[Join & Clean ERP Data<br>- Match customer IDs<br>- Merge locations<br>- Standardize gender]
    B5[bronze.erp_loc_a101] --> T4
    
    %% Silver Results
    T1 --> S1[silver.crm_cust_info<br>Clean Customer Data]
    T2 --> S2[silver.crm_prd_info<br>Clean Product Data]
    T3 --> S3[silver.crm_sales_details<br>Clean Sales Data]
    T4 --> S4[silver.erp_customers<br>Integrated Customer Data]
    
    %% Process Flow
    P0[load_silver Procedure] --> T1 & T2 & T3 & T4
```

The `load_silver` procedure truncates each Silver table then inserts rows from Bronze, applying simple conversions and joins (e.g. ERP customer location data).
