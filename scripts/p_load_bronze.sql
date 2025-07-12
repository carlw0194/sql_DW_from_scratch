/*********************************************************************************************************
 * Object : Stored Procedure [dbo].[load_bronze]
 * Author  : <Your Name>
 * Created : 2025-07-12
 *
 * PURPOSE
 * -------
 * Performs a truncate-and-insert bulk load of all raw CSV extracts into the Bronze schema tables.
 * After each load the procedure returns a TOP (10) preview so callers can verify success.
 *
 * PARAMETERS
 * ----------
 * @DataRoot NVARCHAR(260)  — Absolute directory path that contains the `datasets` folder.
 *                              Example: 'C:\Imports\sql_DW_from_scratch\datasets'
 *
 * USAGE EXAMPLE
 * -------------
 * EXEC dbo.load_bronze @DataRoot = 'C:\Imports\sql_DW_from_scratch\datasets';
 *
 * SECURITY / PERMISSIONS
 * ----------------------
 * Requires: INSERT on target tables and ADMINISTER BULK OPERATIONS (or membership in bulkadmin).
 *
 * WARNING
 * -------
 * This procedure **TRUNCATES** Bronze tables before loading.
 *********************************************************************************************************/
GO

CREATE OR ALTER PROCEDURE dbo.load_bronze
    @DataRoot NVARCHAR(260)
AS
BEGIN TRY
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX);

    /* ---------------- CRM ---------------- */
    PRINT 'Loading bronze.crm_cust_info …';
    DECLARE @start DATETIME2 = SYSDATETIME();
    TRUNCATE TABLE bronze.crm_cust_info;
    SET @sql = N'BULK INSERT bronze.crm_cust_info FROM ' + QUOTENAME(@DataRoot + '\\source_crm\\cust_info.csv', '''') +
               N' WITH (FIRSTROW = 2, FORMAT = ''CSV'', FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'');';
    EXEC (@sql);
    DECLARE @rows INT = @@ROWCOUNT;
    DECLARE @duration_secs INT = DATEDIFF(SECOND, @start, SYSDATETIME());
    SELECT TOP (10) * FROM bronze.crm_cust_info;
    PRINT CONCAT('crm_cust_info: ', @rows, ' rows loaded in ', @duration_secs, ' seconds');

    PRINT 'Loading bronze.crm_prd_info …';
    DECLARE @start_prd DATETIME2 = SYSDATETIME();
    TRUNCATE TABLE bronze.crm_prd_info;
    SET @sql = N'BULK INSERT bronze.crm_prd_info FROM ' + QUOTENAME(@DataRoot + '\\source_crm\\prd_info.csv', '''') +
               N' WITH (FIRSTROW = 2, FORMAT = ''CSV'', FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'');';
    EXEC (@sql);
    DECLARE @rows_prd INT = @@ROWCOUNT;
    DECLARE @duration_secs_prd INT = DATEDIFF(SECOND, @start_prd, SYSDATETIME());
    SELECT TOP (10) * FROM bronze.crm_prd_info;
    PRINT CONCAT('crm_prd_info: ', @rows_prd, ' rows loaded in ', @duration_secs_prd, ' seconds');

    PRINT 'Loading bronze.crm_sales_details …';
    DECLARE @start_sales DATETIME2 = SYSDATETIME();
    TRUNCATE TABLE bronze.crm_sales_details;
    SET @sql = N'BULK INSERT bronze.crm_sales_details FROM ' + QUOTENAME(@DataRoot + '\\source_crm\\sales_details.csv', '''') +
               N' WITH (FIRSTROW = 2, FORMAT = ''CSV'', FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'');';
    EXEC (@sql);
    DECLARE @rows_sales INT = @@ROWCOUNT;
    DECLARE @duration_secs_sales INT = DATEDIFF(SECOND, @start_sales, SYSDATETIME());
    SELECT TOP (10) * FROM bronze.crm_sales_details;
    PRINT CONCAT('crm_sales_details: ', @rows_sales, ' rows loaded in ', @duration_secs_sales, ' seconds');

    /* ---------------- ERP ---------------- */
    PRINT 'Loading bronze.erp_cust_az12 …';
    DECLARE @start_az DATETIME2 = SYSDATETIME();
    TRUNCATE TABLE bronze.erp_cust_az12;
    SET @sql = N'BULK INSERT bronze.erp_cust_az12 FROM ' + QUOTENAME(@DataRoot + '\\source_erp\\CUST_AZ12.csv', '''') +
               N' WITH (FIRSTROW = 2, FORMAT = ''CSV'', FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'');';
    EXEC (@sql);
    DECLARE @rows_az INT = @@ROWCOUNT;
    DECLARE @duration_secs_az INT = DATEDIFF(SECOND, @start_az, SYSDATETIME());
    SELECT TOP (10) * FROM bronze.erp_cust_az12;
    PRINT CONCAT('erp_cust_az12: ', @rows_az, ' rows loaded in ', @duration_secs_az, ' seconds');

    PRINT 'Loading bronze.erp_loc_a101 …';
    DECLARE @start_loc DATETIME2 = SYSDATETIME();
    TRUNCATE TABLE bronze.erp_loc_a101;
    SET @sql = N'BULK INSERT bronze.erp_loc_a101 FROM ' + QUOTENAME(@DataRoot + '\\source_erp\\LOC_A101.csv', '''') +
               N' WITH (FIRSTROW = 2, FORMAT = ''CSV'', FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'');';
    EXEC (@sql);
    DECLARE @rows_loc INT = @@ROWCOUNT;
    DECLARE @duration_secs_loc INT = DATEDIFF(SECOND, @start_loc, SYSDATETIME());
    SELECT TOP (10) * FROM bronze.erp_loc_a101;
    PRINT CONCAT('erp_loc_a101: ', @rows_loc, ' rows loaded in ', @duration_secs_loc, ' seconds');

    PRINT 'Loading bronze.erp_px_cat_g1v2 …';
    DECLARE @start_px DATETIME2 = SYSDATETIME();
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    SET @sql = N'BULK INSERT bronze.erp_px_cat_g1v2 FROM ' + QUOTENAME(@DataRoot + '\\source_erp\\PX_CAT_G1V2.csv', '''') +
               N' WITH (FIRSTROW = 2, FORMAT = ''CSV'', FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'');';
    EXEC (@sql);
    DECLARE @rows_px INT = @@ROWCOUNT;
    DECLARE @duration_secs_px INT = DATEDIFF(SECOND, @start_px, SYSDATETIME());
    SELECT TOP (10) * FROM bronze.erp_px_cat_g1v2;
    PRINT CONCAT('erp_px_cat_g1v2: ', @rows_px, ' rows loaded in ', @duration_secs_px, ' seconds');

    PRINT 'Bronze layer load completed successfully.';
END TRY
BEGIN CATCH
    DECLARE @msg NVARCHAR(2048) = ERROR_MESSAGE();
    RAISERROR ('load_bronze failed: %s', 16, 1, @msg);
END CATCH;
GO
