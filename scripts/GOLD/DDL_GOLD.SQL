 /*
=====================================================================
 DDL Script: Create Gold Views.
=====================================================================
 ## Script Purpose:

 This script creates views for the Gold layer in the data warehouse.

 The Gold layer represents the final dimension and fact tables (Star Schema)

Each view performs transformations and combines data from the Silver layer


to produce a clean, enriched, and business-ready dataset.

 ## Usage:

 These views can be queried directly for analytics and reporting.

==========================================================================
 */

## Create Dimension: gold.dim_customers

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
DROP VIEW gold.dim_customers;

create view gold.dim_customers as
SELECT 
    row_number() over (order by cst_id) as customer_key,
    cst_id as customer_id,
	cst_key as customer_number,
    cst_firstname as firstname,
    cst_lastname as lastname,
	la.CNTRY as country,
    cst_marital_status as marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' then ci.cst_gndr
	     else coalesce(ca.gen,'n/a')
    end gender,
	ca.bdate as birthdate,
	cst_create_date as create_date
from [dbo].[silver.cust_info] as ci
left join [dbo].[silver.CUST_AZ12] ca
on ci.cst_key = ca.cid
left join [dbo].[SILVER.LOC_A101] as la
on		ci.cst_key = la.cid

;
===================================================================================
## Create Dimension:  gold.dim_products

IF OBJECT_ID(' gold.dim_products', 'V') IS NOT NULL
DROP VIEW  gold.dim_products;


create view gold.dim_products as
SELECT
    row_number() over (order by pn.prd_start_dt,pn.prd_key) as prodect_key,
    pn.prd_id as product_id,
	pn.prd_key as product_number,
    pn.prd_nm as product_name,
	pn.cat_id as category_id,
	pc.CAT as category,
	pc.SUBCAT as subcategory,
	pc.MAINTENANCE,
    pn.prd_cost as cost,
    pn.prd_line as product_line,
    pn.prd_start_dt as start_date
from    [dbo].[silver.prd_info] as pn
left join [dbo].[ silver.erp_PX] pc
on pn.cat_id = pc.id
where prd_end_dt is null;

select * from gold.dim_products

;
==========================================================================
## Create Dimension: gold.dm_sales

IF OBJECT_ID(' gold.dm_sales', 'V') IS NOT NULL
DROP VIEW gold.dm_sales;


create view gold.dm_sales as
SELECT 
    sd.sls_ord_num as order_number,
    pr.prodect_key,
	cu.customer_key,
    sd.sls_order_dt as order_date,
    sd.sls_ship_dt as  shipping_date,
    sd.sls_due_dt  as  due_date,
    sd.sls_sales  as sales_amount,
    sd.sls_quantity as quantity,
    sd.sls_price as price
FROM [dbo].[silver.crm_sales] AS sd
LEFT JOIN GOLD.dim_products AS pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN [GOLD].[dim_customers] AS cu
ON sd.sls_cust_id = cu.customer_id
