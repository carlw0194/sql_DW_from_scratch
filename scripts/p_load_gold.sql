/*******************************************************************************
 * Object  : Stored Procedure [dbo].[load_gold]
 * Author  : <Your Name>
 * Created : 2025-07-25
 *
 * PURPOSE
 * -------
 * Populates Gold layer dimension and fact tables from the cleansed Silver layer.
 * Surrogate keys are generated on insert. The example logic is simplified and
 * should be extended to match business requirements.
 *******************************************************************************/
GO

CREATE OR ALTER PROCEDURE dbo.load_gold
AS
BEGIN TRY
    SET NOCOUNT ON;

    /* ===== DIM CUSTOMERS ===== */
    PRINT 'Loading gold.dim_customers';
    TRUNCATE TABLE gold.dim_customers;
    INSERT INTO gold.dim_customers (cst_id, cst_key, firstname, lastname,
                                    gender, birth_date, country)
    SELECT
        c.cst_id,
        c.cst_key,
        c.cst_firstname,
        c.cst_lastname,
        COALESCE(e.gen, CASE WHEN c.cst_gndr = 'M' THEN 'Male' WHEN c.cst_gndr = 'F' THEN 'Female' END) AS gender,
        e.bdate,
        e.cntry
    FROM silver.crm_cust_info AS c
    LEFT JOIN silver.erp_customers AS e
        ON e.cid = CONCAT('NASA', c.cst_key);
    PRINT CONCAT('dim_customers: ', @@ROWCOUNT, ' rows loaded.');

    /* ===== DIM PRODUCTS ===== */
    PRINT 'Loading gold.dim_products';
    TRUNCATE TABLE gold.dim_products;
    INSERT INTO gold.dim_products (prd_key, prd_nm, prd_cost, prd_line,
                                   prd_start_dt, prd_end_dt)
    SELECT prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
    FROM silver.crm_prd_info;
    PRINT CONCAT('dim_products: ', @@ROWCOUNT, ' rows loaded.');

    /* ===== FACT SALES ===== */
    PRINT 'Loading gold.fact_sales';
    TRUNCATE TABLE gold.fact_sales;
    INSERT INTO gold.fact_sales (order_num, product_key, customer_key, order_date,
                                 ship_date, due_date, sales_amt, quantity, unit_price)
    SELECT
        s.sls_ord_num,
        dp.product_key,
        dc.customer_key,
        s.sls_order_dt,
        s.sls_ship_dt,
        s.sls_due_dt,
        s.sls_sales,
        s.sls_quantity,
        s.sls_price
    FROM silver.crm_sales_details AS s
    INNER JOIN gold.dim_products AS dp ON dp.prd_key = s.sls_prd_key
    INNER JOIN gold.dim_customers AS dc ON dc.cst_id = s.sls_cust_id;
    PRINT CONCAT('fact_sales: ', @@ROWCOUNT, ' rows loaded.');

    PRINT 'Gold layer load completed.';
END TRY
BEGIN CATCH
    DECLARE @msg NVARCHAR(2048) = ERROR_MESSAGE();
    RAISERROR ('load_gold failed: %s', 16, 1, @msg);
END CATCH;
GO
