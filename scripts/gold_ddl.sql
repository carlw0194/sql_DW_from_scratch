/*******************************************************************************
 * Script: gold_ddl.sql
 * Author: Carlton Njong
 * Date: 2025-07-25
 *
 * PURPOSE
 * -------
 * Defines the curated analytics layer (Gold). Dimension and fact tables in this
 * schema use business-friendly naming and provide surrogate keys for joining.
 * Only a small subset of attributes is included for demonstration purposes.
 *******************************************************************************/

USE MedallionDW;
GO

/* Ensure gold schema exists */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
    EXEC ('CREATE SCHEMA gold AUTHORIZATION dbo;');
GO

/* ================== DIMENSIONS ================== */

-- dim_customers
IF OBJECT_ID('gold.dim_customers') IS NULL
BEGIN
    CREATE TABLE gold.dim_customers (
        customer_key  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        cst_id        INT           NOT NULL,
        cst_key       NVARCHAR(30)  NOT NULL,
        firstname     NVARCHAR(50)  NOT NULL,
        lastname      NVARCHAR(50)  NOT NULL,
        gender        NVARCHAR(10)  NULL,
        birth_date    DATE          NULL,
        country       NVARCHAR(50)  NULL,
        dwh_load_ts   DATETIME2     NOT NULL DEFAULT (SYSUTCDATETIME())
    );
END;
GO

-- dim_products
IF OBJECT_ID('gold.dim_products') IS NULL
BEGIN
    CREATE TABLE gold.dim_products (
        product_key  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        prd_key      NVARCHAR(60)  NOT NULL,
        prd_nm       NVARCHAR(120) NULL,
        prd_cost     DECIMAL(18,2) NULL,
        prd_line     CHAR(1)       NULL,
        prd_start_dt DATE          NULL,
        prd_end_dt   DATE          NULL,
        dwh_load_ts  DATETIME2     NOT NULL DEFAULT (SYSUTCDATETIME())
    );
END;
GO

/* ================== FACTS ================== */

-- fact_sales
IF OBJECT_ID('gold.fact_sales') IS NULL
BEGIN
    CREATE TABLE gold.fact_sales (
        sales_key    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        order_num    NVARCHAR(20)  NOT NULL,
        product_key  INT           NOT NULL,
        customer_key INT           NOT NULL,
        order_date   DATE          NULL,
        ship_date    DATE          NULL,
        due_date     DATE          NULL,
        sales_amt    DECIMAL(18,2) NULL,
        quantity     INT           NULL,
        unit_price   DECIMAL(18,2) NULL,
        dwh_load_ts  DATETIME2     NOT NULL DEFAULT (SYSUTCDATETIME())
    );
END;
GO

PRINT 'Gold DDL executed successfully.';
GO
