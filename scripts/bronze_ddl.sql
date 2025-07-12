/*********************************************************************************************************
 * Script: bronze_ddl.sql
 * Author: <Your Name>
 * Date: 2025-07-12
 *
 * PURPOSE
 * -------
 * DDL to create raw (Bronze) tables in schema [bronze] following established naming conventions
 * for CRM and ERP source extracts.
 *
 * WARNING
 * -------
 * • This script **creates or replaces** baseline tables. Run only after provisioning the database & schema.
 * • It is **idempotent**: uses IF NOT EXISTS checks to avoid accidental drops.
 *********************************************************************************************************/

USE MedallionDW;
GO

/* ============ Helper: create schema if missing ============ */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
    EXEC ('CREATE SCHEMA bronze AUTHORIZATION dbo;');
GO

/* =========================================================== */
/* =====================  CRM TABLES  ======================== */
/* =========================================================== */

/* --- crm_cust_info --- */
IF OBJECT_ID('bronze.crm_cust_info') IS NULL
BEGIN
    CREATE TABLE bronze.crm_cust_info (
        cst_id               INT             NULL,
        cst_key              NVARCHAR(30)    NULL,
        cst_firstname        NVARCHAR(50)    NULL,
        cst_lastname         NVARCHAR(50)    NULL,
        cst_marital_status   CHAR(1)         NULL,
        cst_gndr             CHAR(1)         NULL,
        cst_create_date      DATE            NULL,
        dwh_ingest_ts        DATETIME2       NOT NULL DEFAULT (SYSUTCDATETIME())
    );
END;
GO

/* --- crm_prd_info --- */
IF OBJECT_ID('bronze.crm_prd_info') IS NULL
BEGIN
    CREATE TABLE bronze.crm_prd_info (
        prd_id        INT             NULL,
        prd_key       NVARCHAR(60)    NULL,
        prd_nm        NVARCHAR(120)   NULL,
        prd_cost      DECIMAL(18,2)   NULL,
        prd_line      CHAR(1)         NULL,
        prd_start_dt  DATE            NULL,
        prd_end_dt    DATE            NULL,
        dwh_ingest_ts DATETIME2       NOT NULL DEFAULT (SYSUTCDATETIME())
    );
END;
GO

/* --- crm_sales_details --- */
IF OBJECT_ID('bronze.crm_sales_details') IS NULL
BEGIN
    CREATE TABLE bronze.crm_sales_details (
        sls_ord_num   NVARCHAR(20)    NULL,
        sls_prd_key   NVARCHAR(60)    NULL,
        sls_cust_id   INT             NULL,
        sls_order_dt  DATE            NULL,
        sls_ship_dt   DATE            NULL,
        sls_due_dt    DATE            NULL,
        sls_sales     DECIMAL(18,2)   NULL,
        sls_quantity  INT             NULL,
        sls_price     DECIMAL(18,2)   NULL,
        dwh_ingest_ts DATETIME2       NOT NULL DEFAULT (SYSUTCDATETIME())
    );
END;
GO

/* =========================================================== */
/* =====================  ERP TABLES  ======================== */
/* =========================================================== */

/* --- erp_cust_az12 --- */
IF OBJECT_ID('bronze.erp_cust_az12') IS NULL
BEGIN
    CREATE TABLE bronze.erp_cust_az12 (
        cid           NVARCHAR(30)    NULL,
        bdate         DATE            NULL,
        gen           NVARCHAR(10)    NULL,
        dwh_ingest_ts DATETIME2       NOT NULL DEFAULT (SYSUTCDATETIME())
    );
END;
GO

/* --- erp_loc_a101 --- */
IF OBJECT_ID('bronze.erp_loc_a101') IS NULL
BEGIN
    CREATE TABLE bronze.erp_loc_a101 (
        cid           NVARCHAR(30)    NULL,
        cntry         NVARCHAR(50)    NULL,
        dwh_ingest_ts DATETIME2       NOT NULL DEFAULT (SYSUTCDATETIME())
    );
END;
GO

/* --- erp_px_cat_g1v2 --- */
IF OBJECT_ID('bronze.erp_px_cat_g1v2') IS NULL
BEGIN
    CREATE TABLE bronze.erp_px_cat_g1v2 (
        id            NVARCHAR(20)    NULL,
        cat           NVARCHAR(50)    NULL,
        subcat        NVARCHAR(50)    NULL,
        maintenance   NVARCHAR(3)     NULL,
        dwh_ingest_ts DATETIME2       NOT NULL DEFAULT (SYSUTCDATETIME())
    );
END;
GO

PRINT 'Bronze DDL executed successfully.';
GO
