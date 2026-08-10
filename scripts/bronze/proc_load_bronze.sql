/*
===============================================================================
Bronze Layer: Truncate and Validate Tables
===============================================================================

Script Purpose:
    This script clears all Bronze layer tables before reloading source data.
    After each import, the SELECT statements can be used to inspect the loaded
    records and verify the total number of rows.

    Recommended workflow:
        1. Truncate the target Bronze table.
        2. Import the corresponding CSV file using DBeaver.
        3. Preview the loaded data.
        4. Validate the row count.
===============================================================================
*/


-- ============================================================================
-- CRM Customer Information
-- Source file: datasets/source_crm/cust_info.csv
-- ============================================================================

TRUNCATE TABLE bronze.crm_cust_info;

SELECT *
FROM bronze.crm_cust_info;

SELECT COUNT(*)
FROM bronze.crm_cust_info;


-- ============================================================================
-- CRM Product Information
-- Source file: datasets/source_crm/prd_info.csv
-- ============================================================================

TRUNCATE TABLE bronze.crm_prd_info;

SELECT *
FROM bronze.crm_prd_info;

SELECT COUNT(*)
FROM bronze.crm_prd_info;


-- ============================================================================
-- CRM Sales Details
-- Source file: datasets/source_crm/sales_details.csv
-- ============================================================================

TRUNCATE TABLE bronze.crm_sales_details;

SELECT *
FROM bronze.crm_sales_details;

SELECT COUNT(*)
FROM bronze.crm_sales_details;


-- ============================================================================
-- ERP Customer Information
-- Source file: datasets/source_erp/CUST_AZ12.csv
-- ============================================================================

TRUNCATE TABLE bronze.erp_cust_az12;

SELECT *
FROM bronze.erp_cust_az12;

SELECT COUNT(*)
FROM bronze.erp_cust_az12;


-- ============================================================================
-- ERP Customer Location
-- Source file: datasets/source_erp/LOC_A101.csv
-- ============================================================================

TRUNCATE TABLE bronze.erp_loc_a101;

SELECT *
FROM bronze.erp_loc_a101;

SELECT COUNT(*)
FROM bronze.erp_loc_a101;


-- ============================================================================
-- ERP Product Category Information
-- Source file: datasets/source_erp/PX_CAT_G1V2.csv
-- ============================================================================

TRUNCATE TABLE bronze.erp_px_cat_g1v2;

SELECT *
FROM bronze.erp_px_cat_g1v2;

SELECT COUNT(*)
FROM bronze.erp_px_cat_g1v2;