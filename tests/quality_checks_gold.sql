/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Script Purpose:
    This script performs quality checks on the Gold layer of the data warehouse.

    The checks validate:
    - Duplicate records after joins.
    - Correct gender matching and source precedence.
    - Duplicate dimension keys.
    - Product dimension consistency.
    - Referential integrity between fact and dimension views.

Expectation:
    Queries marked with "Expectation: No Result" should return no rows.
===============================================================================
*/


-- =============================================================================
-- CUSTOMER DIMENSION
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Check for duplicates after joining customer-related Silver tables
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT
    cst_id,
    COUNT(*) AS record_count
FROM (
    SELECT
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_marital_status,
        ci.cst_gndr,
        ci.cst_create_date,
        ca.bdate,
        ca.gen,
        la.cntry
    FROM silver.crm_cust_info ci

    LEFT JOIN silver.erp_cust_az12 ca
        ON ci.cst_key = ca.cid

    LEFT JOIN silver.erp_loc_a101 la
        ON ci.cst_key = la.cid
) t
GROUP BY cst_id
HAVING COUNT(*) > 1;


-- -----------------------------------------------------------------------------
-- Check gender matching and source precedence
-- CRM is treated as the master source for gender information
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    ci.cst_gndr,
    ca.gen,

    CASE
        WHEN ci.cst_gndr != 'n/a'
            THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS new_gen

FROM silver.crm_cust_info ci

LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid

ORDER BY 1, 2;


-- -----------------------------------------------------------------------------
-- Preview customer dimension
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.dim_customers;


-- -----------------------------------------------------------------------------
-- Check standardized gender values
-- -----------------------------------------------------------------------------

SELECT DISTINCT gender
FROM gold.dim_customers;


-- -----------------------------------------------------------------------------
-- Check for duplicate customer keys
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT
    customer_key,
    COUNT(*) AS record_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- -----------------------------------------------------------------------------
-- Check for duplicate customer IDs
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT
    customer_id,
    COUNT(*) AS record_count
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;



-- =============================================================================
-- PRODUCT DIMENSION
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Check for duplicates after joining product-related Silver tables
-- Only current products are included
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT
    prd_key,
    COUNT(*) AS record_count
FROM (
    SELECT
        pn.prd_id,
        pn.cat_id,
        pn.prd_key,
        pn.prd_nm,
        pn.prd_cost,
        pn.prd_line,
        pn.prd_start_dt,
        pn.prd_end_dt,
        pc.cat,
        pc.subcat,
        pc.maintenance

    FROM silver.crm_prd_info pn

    LEFT JOIN silver.erp_px_cat_g1v2 pc
        ON pn.cat_id = pc.id

    WHERE prd_end_dt IS NULL -- Filter out historical data
) t
GROUP BY prd_key
HAVING COUNT(*) > 1;


-- -----------------------------------------------------------------------------
-- Preview product dimension
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.dim_products;


-- -----------------------------------------------------------------------------
-- Check for duplicate product keys
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT
    product_key,
    COUNT(*) AS record_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- -----------------------------------------------------------------------------
-- Check for duplicate product numbers
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT
    product_number,
    COUNT(*) AS record_count
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;



-- =============================================================================
-- SALES FACT
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Check fact table joined with customer and product dimensions
-- Expectation: No missing dimension references
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.fact_sales f

LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key

LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key

WHERE c.customer_key IS NULL
   OR p.product_key IS NULL;


-- -----------------------------------------------------------------------------
-- Additional check: NULL dimension keys in fact table
-- Expectation: No Result
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.fact_sales
WHERE customer_key IS NULL
   OR product_key IS NULL;