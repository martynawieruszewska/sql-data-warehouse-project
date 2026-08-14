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

