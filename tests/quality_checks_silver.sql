/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Script Purpose:
    This script performs quality checks on data in the Bronze and Silver layers.

    The checks validate:
    - Null or duplicate primary keys
    - Unwanted spaces
    - Data standardization and consistency
    - Invalid dates and date ranges
    - Invalid chronological relationships
    - Sales, quantity, and price consistency
    - Correct transformation of data from Bronze to Silver

Expectation:
    Queries marked with "Expectation: No Result" should return no rows
    after data has been correctly transformed into the Silver layer.
===============================================================================
*/


-- =============================================================================
-- CRM CUSTOMER INFO
-- =============================================================================


-- -----------------------------------------------------------------------------
-- BRONZE: Check for NULLs or duplicates in customer ID
-- Expectation: May return results in Bronze
-- -----------------------------------------------------------------------------

SELECT
    cst_id,
    COUNT(*) AS record_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


-- -----------------------------------------------------------------------------
-- BRONZE: Check for unwanted spaces
-- -----------------------------------------------------------------------------

SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);


-- -----------------------------------------------------------------------------
-- BRONZE: Check data standardization and consistency
-- -----------------------------------------------------------------------------

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;


-- -----------------------------------------------------------------------------
-- SILVER: Check for NULLs or duplicates in customer ID
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT
    cst_id,
    COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


-- -----------------------------------------------------------------------------
-- SILVER: Check for unwanted spaces
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);


-- -----------------------------------------------------------------------------
-- SILVER: Check standardized categorical values
-- -----------------------------------------------------------------------------

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;


-- -----------------------------------------------------------------------------
-- SILVER: Preview transformed customer data
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.crm_cust_info;



-- =============================================================================
-- CRM PRODUCT INFO
-- =============================================================================


-- -----------------------------------------------------------------------------
-- BRONZE: Preview source data
-- -----------------------------------------------------------------------------

SELECT *
FROM bronze.crm_prd_info;


-- -----------------------------------------------------------------------------
-- BRONZE: Check for NULLs or duplicates in product ID
-- -----------------------------------------------------------------------------

SELECT
    prd_id,
    COUNT(*) AS record_count
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


-- -----------------------------------------------------------------------------
-- BRONZE: Check for unwanted spaces in product name
-- -----------------------------------------------------------------------------

SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- -----------------------------------------------------------------------------
-- BRONZE: Check invalid or missing product costs
-- -----------------------------------------------------------------------------

SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0
   OR prd_cost IS NULL;


-- -----------------------------------------------------------------------------
-- BRONZE: Check product line consistency
-- -----------------------------------------------------------------------------

SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;


-- -----------------------------------------------------------------------------
-- BRONZE: Check for invalid date order
-- -----------------------------------------------------------------------------

SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- -----------------------------------------------------------------------------
-- BRONZE: Validate calculated product end date
-- -----------------------------------------------------------------------------

SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_start_dt,
    prd_end_dt,
    LEAD(prd_start_dt) OVER (
        PARTITION BY prd_key
        ORDER BY prd_start_dt
    ) - INTERVAL '1 day' AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN (
    'AC-HE-HL-U509-R',
    'AC-HE-HL-U509'
);


-- -----------------------------------------------------------------------------
-- SILVER: Check for NULLs or duplicates in product ID
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT
    prd_id,
    COUNT(*) AS record_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


-- -----------------------------------------------------------------------------
-- SILVER: Check for unwanted spaces
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- -----------------------------------------------------------------------------
-- SILVER: Check invalid or missing product costs
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0
   OR prd_cost IS NULL;


-- -----------------------------------------------------------------------------
-- SILVER: Check standardized product lines
-- -----------------------------------------------------------------------------

SELECT DISTINCT prd_line
FROM silver.crm_prd_info;


-- -----------------------------------------------------------------------------
-- SILVER: Check for invalid date order
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- -----------------------------------------------------------------------------
-- SILVER: Preview transformed product data
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.crm_prd_info;



-- =============================================================================
-- CRM SALES DETAILS
-- =============================================================================


-- -----------------------------------------------------------------------------
-- BRONZE: Check unwanted spaces in order number
-- -----------------------------------------------------------------------------

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);


-- -----------------------------------------------------------------------------
-- BRONZE: Check invalid order dates
-- -----------------------------------------------------------------------------

SELECT
    sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
   OR LENGTH(sls_order_dt::TEXT) != 8;


-- -----------------------------------------------------------------------------
-- BRONZE: Check invalid shipping dates
-- -----------------------------------------------------------------------------

SELECT
    NULLIF(sls_ship_dt, 0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0
   OR LENGTH(sls_ship_dt::TEXT) != 8
   OR sls_ship_dt > 20500101
   OR sls_ship_dt < 19000101;


-- -----------------------------------------------------------------------------
-- BRONZE: Check invalid due dates
-- -----------------------------------------------------------------------------

SELECT
    NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR LENGTH(sls_due_dt::TEXT) != 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;


-- -----------------------------------------------------------------------------
-- BRONZE: Check invalid chronological order of dates
-- Expectation:
-- Order Date <= Ship Date
-- Order Date <= Due Date
-- -----------------------------------------------------------------------------

SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;


-- -----------------------------------------------------------------------------
-- BRONZE: Check consistency between Sales, Quantity and Price
-- Expectation:
-- Sales = Quantity * Price
-- Values must not be NULL, zero or negative
-- -----------------------------------------------------------------------------

SELECT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
   OR sls_sales != sls_quantity * ABS(sls_price);


-- -----------------------------------------------------------------------------
-- SILVER: Check invalid dates after transformation
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt IS NOT NULL
  AND sls_order_dt > CURRENT_DATE;

SELECT *
FROM silver.crm_sales_details
WHERE sls_ship_dt IS NOT NULL
  AND sls_ship_dt > CURRENT_DATE;

SELECT *
FROM silver.crm_sales_details
WHERE sls_due_dt IS NOT NULL
  AND sls_due_dt > CURRENT_DATE;


-- -----------------------------------------------------------------------------
-- SILVER: Check invalid chronological order
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;


-- -----------------------------------------------------------------------------
-- SILVER: Check Sales, Quantity and Price consistency
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
   OR sls_sales != sls_quantity * sls_price;


-- -----------------------------------------------------------------------------
-- SILVER: Preview transformed sales data
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.crm_sales_details;



-- =============================================================================
-- ERP CUSTOMER AZ12
-- =============================================================================


-- -----------------------------------------------------------------------------
-- BRONZE: Preview source data
-- -----------------------------------------------------------------------------

SELECT
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12;


-- -----------------------------------------------------------------------------
-- BRONZE: Check customer ID prefix
-- -----------------------------------------------------------------------------

SELECT
    cid
FROM bronze.erp_cust_az12
WHERE cid LIKE 'NAS%';


-- -----------------------------------------------------------------------------
-- BRONZE: Identify out-of-range birth dates
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    bdate
FROM bronze.erp_cust_az12
WHERE bdate < DATE '1924-01-01'
   OR bdate > CURRENT_DATE;


-- -----------------------------------------------------------------------------
-- BRONZE: Check gender values
-- -----------------------------------------------------------------------------

SELECT DISTINCT gen
FROM bronze.erp_cust_az12;


-- -----------------------------------------------------------------------------
-- SILVER: Check customer IDs after NAS prefix removal
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT
    cid
FROM silver.erp_cust_az12
WHERE cid LIKE 'NAS%';


-- -----------------------------------------------------------------------------
-- SILVER: Check invalid future birth dates
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate > CURRENT_DATE;


-- -----------------------------------------------------------------------------
-- SILVER: Check standardized gender values
-- -----------------------------------------------------------------------------

SELECT DISTINCT gen
FROM silver.erp_cust_az12;


-- -----------------------------------------------------------------------------
-- SILVER: Preview transformed ERP customer data
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.erp_cust_az12;



-- =============================================================================
-- ERP LOCATION A101
-- =============================================================================


-- -----------------------------------------------------------------------------
-- BRONZE: Preview source data
-- -----------------------------------------------------------------------------

SELECT
    cid,
    cntry
FROM bronze.erp_loc_a101;


-- -----------------------------------------------------------------------------
-- BRONZE: Check country values
-- -----------------------------------------------------------------------------

SELECT DISTINCT cntry
FROM bronze.erp_loc_a101;


-- -----------------------------------------------------------------------------
-- BRONZE: Check customer IDs containing hyphens
-- -----------------------------------------------------------------------------

SELECT cid
FROM bronze.erp_loc_a101
WHERE cid LIKE '%-%';


-- -----------------------------------------------------------------------------
-- SILVER: Check standardized customer IDs
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT cid
FROM silver.erp_loc_a101
WHERE cid LIKE '%-%';


-- -----------------------------------------------------------------------------
-- SILVER: Check standardized country values
-- -----------------------------------------------------------------------------

SELECT DISTINCT cntry
FROM silver.erp_loc_a101;


-- -----------------------------------------------------------------------------
-- SILVER: Check missing country values
-- Expectation: No NULL or blank values
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.erp_loc_a101
WHERE cntry IS NULL
   OR TRIM(cntry) = '';


-- -----------------------------------------------------------------------------
-- SILVER: Preview transformed location data
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.erp_loc_a101;



-- =============================================================================
-- ERP PRODUCT CATEGORY G1V2
-- =============================================================================


-- -----------------------------------------------------------------------------
-- BRONZE: Preview source data
-- -----------------------------------------------------------------------------

SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;


-- -----------------------------------------------------------------------------
-- BRONZE: Check category values
-- -----------------------------------------------------------------------------

SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;


-- -----------------------------------------------------------------------------
-- BRONZE: Check unwanted spaces
-- -----------------------------------------------------------------------------

SELECT cat
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat);

SELECT subcat
FROM bronze.erp_px_cat_g1v2
WHERE subcat != TRIM(subcat);


-- -----------------------------------------------------------------------------
-- SILVER: Check unwanted spaces
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT cat
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat);

SELECT subcat
FROM silver.erp_px_cat_g1v2
WHERE subcat != TRIM(subcat);


-- -----------------------------------------------------------------------------
-- SILVER: Check category consistency
-- -----------------------------------------------------------------------------

SELECT DISTINCT cat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2;


-- -----------------------------------------------------------------------------
-- SILVER: Preview transformed product category data
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.erp_px_cat_g1v2;