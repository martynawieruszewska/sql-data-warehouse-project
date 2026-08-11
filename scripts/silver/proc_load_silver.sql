INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status, -- more readable format
    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr, -- more readable format
    cst_create_date
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS flag_last
    FROM bronze.crm_cust_info
) t
WHERE flag_last = 1; -- without duplicates

insert into silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
select 
prd_id,
replace(substring(prd_key from 1 for 5), '-', '_') as cat_id, -- extract cat id
substring(prd_key from 7 for length(prd_key)) as prd_key, -- extracy prod key
prd_nm,
coalesce(prd_cost, 0),
case upper(trim(prd_line))
	when 'M' then 'Mountain'
	when 'S' then 'other Sales'
	when 'R' then 'Road' 
	when 'T' then 'Touring'
	else 'n/a'
end prd_line, -- more readable format
prd_start_dt::date,
(LEAD(prd_start_dt) OVER (
        PARTITION BY prd_key
        ORDER BY prd_start_dt
    ) - INTERVAL '1 day')::date AS prd_end_dt -- correct date
from bronze.crm_prd_info
