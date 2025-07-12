/*********************************************************************************************************
 * Script: create_medallion_dw.sql
 * Author: <Your Name>
 * Date: 2025-07-12
 *
 * PURPOSE
 * -------
 * 1. Creates a dedicated SQL Server database for the Medallion-style data-warehouse.
 * 2. Inside that database, creates baseline schemas representing each quality layer:
 *       • bronze   – raw ingestion layer  (immutable, minimal transformation)
 *       • silver   – cleansed & conformed layer
 *       • gold     – curated analytics layer
 *
 * WARNING
 * -------
 * THIS SCRIPT MAY **DROP** THE TARGET DATABASE IF IT ALREADY EXISTS (controlled by the @ForceRecreate flag).
 * Execute ONLY in non-production environments unless you have verified backups and change-management approvals.
 *
 * SAFE RUN GUIDELINES
 * ------------------
 * 1. Review the @DatabaseName and @ForceRecreate parameters below and set them appropriately.
 * 2. Run in SQL Server Management Studio (SSMS) or sqlcmd with sufficient privileges (CREATE DATABASE, etc.).
 * 3. Commit this file to version control so it is auditable and repeatable.
 *********************************************************************************************************/

/*========================= USER-ADJUSTABLE PARAMETERS =========================*/
DECLARE @DatabaseName   SYSNAME = N'MedallionDW';  -- Change if you prefer a different DB name
DECLARE @ForceRecreate  BIT     = 0;               -- Set to 1 to drop & recreate if DB exists
/*=============================================================================*/

/* -----[ 1. (Optional) Drop existing database ]----- */
IF DB_ID(@DatabaseName) IS NOT NULL AND @ForceRecreate = 1
BEGIN
    PRINT CONCAT('Dropping existing database ', @DatabaseName, ' …');
    ALTER DATABASE QUOTENAME(@DatabaseName) SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QUOTENAME(@DatabaseName);
END;

/* -----[ 2. Create database if it does not exist ]----- */
IF DB_ID(@DatabaseName) IS NULL
BEGIN
    PRINT CONCAT('Creating database ', @DatabaseName, ' …');
    DECLARE @sql NVARCHAR(MAX) = N'CREATE DATABASE ' + QUOTENAME(@DatabaseName) + N';';
    EXEC (@sql);
END;
GO

/* -----[ 3. Switch context to the new database ]----- */
USE QUOTENAME(@DatabaseName);
GO

/* -----[ 4. Create Medallion schemas ]----- */
SET NOCOUNT ON;
DECLARE @schemas TABLE (SchemaName SYSNAME);
INSERT INTO @schemas(SchemaName) VALUES
    (N'bronze'),
    (N'silver'),
    (N'gold');

DECLARE @schemaName SYSNAME, @sql NVARCHAR(MAX);
DECLARE schema_cursor CURSOR FOR SELECT SchemaName FROM @schemas;
OPEN schema_cursor;
FETCH NEXT FROM schema_cursor INTO @schemaName;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = @schemaName)
    BEGIN
        PRINT CONCAT('Creating schema ', @schemaName, ' …');
        SET @sql = N'CREATE SCHEMA ' + QUOTENAME(@schemaName) + N' AUTHORIZATION dbo;';
        EXEC (@sql);
    END
    ELSE
    BEGIN
        PRINT CONCAT('Schema ', @schemaName, ' already exists – skipping.');
    END
    FETCH NEXT FROM schema_cursor INTO @schemaName;
END
CLOSE schema_cursor;
DEALLOCATE schema_cursor;
GO

PRINT 'Medallion database & schemas successfully provisioned.';
GO
