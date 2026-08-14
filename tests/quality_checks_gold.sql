-- Customer
-- Checking for duplicates after joins

select cst_id, count(*) from (
select
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
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key = ca.cid 
left join silver.erp_loc_a101 la
on ci.cst_key = la.cid 
)t group by cst_id 
having count(*) > 1

-- Matching gender
select distinct
	ci.cst_gndr,
	ca.gen,
	case 
		when ci.cst_gndr != 'n/a' then ci.cst_gndr -- CRM is the Master for gender info
		else coalesce(ca.gen, 'n/a')
	end as new_gen
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key = ca.cid 
left join silver.erp_loc_a101 la
on ci.cst_key = la.cid 
order by 1, 2

-- Quality check
select * from gold.dim_customers
select distinct gender from gold.dim_customers

-- Product

-- Duplicates
select prd_key, count(*) from  (
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
left join silver.erp_px_cat_g1v2 pc
on pn.cat_id = pc.id
where prd_end_dt is null -- filtered out historical data
)t group by prd_key
having count(*) > 1

select * from gold.dim_products


-- Sales
select  * from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
left join gold.dim_products p
on p.product_key = f.product_key
where c.customer_key is null or p.product_key is null