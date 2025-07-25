/*******************************************************************************
 * Script: silver_ddl.sql
 * Author: <Your Name>
 * Date: 2025-07-25
 *
 * PURPOSE
 * -------
 * Creates typed tables in schema [silver] that store cleansed versions of the
 * raw Bronze data. The table names mirror the source system names to keep a
 * clear lineage back to the original extracts.
 *
 * These structures are intentionally simple. They capture the minimum required
 * columns with explicit data types and basic constraints so that downstream
 * pipelines can rely on consistent formatting.
 *******************************************************************************/

USE MedallionDW;
GO

/* Ensure silver schema exists */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC ('CREATE SCHEMA silver AUTHORIZATION dbo;');
GO

/* ================== CRM TABLES ================== */

-- crm_cust_info
IF OBJECT_ID('silver.crm_cust_info') IS NULL
BEGIN
    CREATE TABLE silver.crm_cust_info (
        cst_id             INT            NOT NULL,
        cst_key            NVARCHAR(30)   NOT NULL,
        cst_firstname      NVARCHAR(50)   NOT NULL,
        cst_lastname       NVARCHAR(50)   NOT NULL,
        cst_marital_status CHAR(1)        NULL,
        cst_gndr           CHAR(1)        NULL,
        cst_create_date    DATE           NULL,
        dwh_ingest_ts      DATETIME2      NOT NULL DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_silver_crm_cust_info PRIMARY KEY (cst_id)
    );
END;
GO

-- crm_prd_info
IF OBJECT_ID('silver.crm_prd_info') IS NULL
BEGIN
    CREATE TABLE silver.crm_prd_info (
        prd_id        INT            NOT NULL,
        prd_key       NVARCHAR(60)   NOT NULL,
        prd_nm        NVARCHAR(120)  NULL,
        prd_cost      DECIMAL(18,2)  NULL,
        prd_line      CHAR(1)        NULL,
        prd_start_dt  DATE           NULL,
        prd_end_dt    DATE           NULL,
        dwh_ingest_ts DATETIME2      NOT NULL DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_silver_crm_prd_info PRIMARY KEY (prd_id, prd_key)
    );
END;
GO

-- crm_sales_details
IF OBJECT_ID('silver.crm_sales_details') IS NULL
BEGIN
    CREATE TABLE silver.crm_sales_details (
        sls_ord_num   NVARCHAR(20)   NOT NULL,
        sls_prd_key   NVARCHAR(60)   NOT NULL,
        sls_cust_id   INT            NOT NULL,
        sls_order_dt  DATE           NULL,
        sls_ship_dt   DATE           NULL,
        sls_due_dt    DATE           NULL,
        sls_sales     DECIMAL(18,2)  NULL,
        sls_quantity  INT            NULL,
        sls_price     DECIMAL(18,2)  NULL,
        dwh_ingest_ts DATETIME2      NOT NULL DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_silver_crm_sales_details PRIMARY KEY (sls_ord_num, sls_prd_key)
    );
END;
GO

/* ================== ERP TABLES ================== */

-- erp_customers (joined view of az12 + location)
IF OBJECT_ID('silver.erp_customers') IS NULL
BEGIN
    CREATE TABLE silver.erp_customers (
        cid           NVARCHAR(30)   NOT NULL,
        bdate         DATE           NULL,
        gen           NVARCHAR(10)   NULL,
        cntry         NVARCHAR(50)   NULL,
        dwh_ingest_ts DATETIME2      NOT NULL DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_silver_erp_customers PRIMARY KEY (cid)
    );
END;
GO

-- erp_px_cat_g1v2
IF OBJECT_ID('silver.erp_px_cat_g1v2') IS NULL
BEGIN
    CREATE TABLE silver.erp_px_cat_g1v2 (
        id            NVARCHAR(20)   NOT NULL,
        cat           NVARCHAR(50)   NULL,
        subcat        NVARCHAR(50)   NULL,
        maintenance   NVARCHAR(3)    NULL,
        dwh_ingest_ts DATETIME2      NOT NULL DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_silver_erp_px_cat_g1v2 PRIMARY KEY (id)
    );
END;
GO

PRINT 'Silver DDL executed successfully.';
GO
