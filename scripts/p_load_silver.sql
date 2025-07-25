/*******************************************************************************
 * Object  : Stored Procedure [dbo].[load_silver]
 * Author  :Carlton Njong
 * Created : 2025-07-25
 *
 * PURPOSE
 * -------
 * Transforms Bronze tables into their cleaned Silver equivalents. This procedure
 * is intentionally lightweight and should be adapted to project-specific rules.
 * Examples include trimming whitespace, enforcing data types and joining related
 * ERP tables.
 *******************************************************************************/
GO

CREATE OR ALTER PROCEDURE dbo.load_silver
AS
BEGIN TRY
    SET NOCOUNT ON;

    /* ----- CRM CUSTOMER INFO ----- */
    PRINT 'Transforming crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;
    INSERT INTO silver.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname,
                                      cst_marital_status, cst_gndr, cst_create_date)
    SELECT
        cst_id,
        LTRIM(RTRIM(cst_key)),
        LTRIM(RTRIM(cst_firstname)),
        LTRIM(RTRIM(cst_lastname)),
        cst_marital_status,
        cst_gndr,
        cst_create_date
    FROM bronze.crm_cust_info;
    PRINT CONCAT('crm_cust_info: ', @@ROWCOUNT, ' rows loaded.');

    /* ----- CRM PRODUCT INFO ----- */
    PRINT 'Transforming crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;
    INSERT INTO silver.crm_prd_info (prd_id, prd_key, prd_nm, prd_cost,
                                     prd_line, prd_start_dt, prd_end_dt)
    SELECT
        prd_id,
        LTRIM(RTRIM(prd_key)),
        LTRIM(RTRIM(prd_nm)),
        TRY_CAST(prd_cost AS DECIMAL(18,2)),
        prd_line,
        prd_start_dt,
        prd_end_dt
    FROM bronze.crm_prd_info;
    PRINT CONCAT('crm_prd_info: ', @@ROWCOUNT, ' rows loaded.');

    /* ----- CRM SALES DETAILS ----- */
    PRINT 'Transforming crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;
    INSERT INTO silver.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id,
                                          sls_order_dt, sls_ship_dt, sls_due_dt,
                                          sls_sales, sls_quantity, sls_price)
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        TRY_CONVERT(DATE, sls_order_dt),
        TRY_CONVERT(DATE, sls_ship_dt),
        TRY_CONVERT(DATE, sls_due_dt),
        sls_sales,
        sls_quantity,
        sls_price
    FROM bronze.crm_sales_details;
    PRINT CONCAT('crm_sales_details: ', @@ROWCOUNT, ' rows loaded.');

    /* ----- ERP CUSTOMERS (join location) ----- */
    PRINT 'Transforming erp_customers';
    TRUNCATE TABLE silver.erp_customers;
    INSERT INTO silver.erp_customers (cid, bdate, gen, cntry)
    SELECT
        a.cid,
        a.bdate,
        a.gen,
        l.cntry
    FROM bronze.erp_cust_az12 AS a
    LEFT JOIN bronze.erp_loc_a101 AS l
        ON REPLACE(l.cid, 'AW-', 'NASAW') = a.cid;
    PRINT CONCAT('erp_customers: ', @@ROWCOUNT, ' rows loaded.');

    /* ----- ERP CATEGORY LOOKUP ----- */
    PRINT 'Transforming erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    SELECT
        id,
        LTRIM(RTRIM(cat)),
        LTRIM(RTRIM(subcat)),
        maintenance
    FROM bronze.erp_px_cat_g1v2;
    PRINT CONCAT('erp_px_cat_g1v2: ', @@ROWCOUNT, ' rows loaded.');

    PRINT 'Silver layer load completed.';
END TRY
BEGIN CATCH
    DECLARE @msg NVARCHAR(2048) = ERROR_MESSAGE();
    RAISERROR ('load_silver failed: %s', 16, 1, @msg);
END CATCH;
GO
