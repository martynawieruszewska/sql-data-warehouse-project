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

insert into silver.crm_sales_details (
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
)
select 
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE
    WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt::TEXT) != 8
    THEN NULL
    ELSE TO_DATE(sls_order_dt::TEXT, 'YYYYMMDD')
END AS sls_order_dt,
CASE
    WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt::TEXT) != 8
    THEN NULL
    ELSE TO_DATE(sls_ship_dt::TEXT, 'YYYYMMDD')
END AS sls_ship_dt,
CASE
    WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt::TEXT) != 8
    THEN NULL
    ELSE TO_DATE(sls_due_dt::TEXT, 'YYYYMMDD')
END AS sls_due_dt,
case 
	when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price) then sls_quantity * abs(sls_price)
	else sls_sales
end as sls_sales,
sls_quantity,
case
	when sls_price is null or sls_price <= 0 then sls_sales / coalesce(sls_quantity, 0)
	else sls_price
end as sls_price
from bronze.crm_sales_details

insert into silver.erp_cust_az12(
	cid,
	bdate,
	gen)
select
case 
	when cid like 'NAS%' then substring(cid from 4 for length(cid))
	else cid
end as cid, -- remove 'nas' pefix
case 
	when bdate > current_date then null 
	else bdate
end as bdate, -- set future bdates to null
case 
	when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
	when upper(trim(gen)) in ('M', 'Male') then 'Male'
	else 'n/a'
end as gen -- normalize gender
from bronze.erp_cust_az12

insert into silver.erp_loc_a101 (
	cid,
	cntry)
select
replace(cid, '-', '') as cid,
case 
	when trim(cntry) = 'DE' then 'Germany'
	when trim(cntry) in ('US', 'USA') then 'United States'
	when trim(cntry) = '' or cntry is null then 'n/a'
	else trim(cntry)
end as cntry -- normalize and handle missing or blank country codes
from bronze.erp_loc_a101




