/*
========================================================================================
 ## Quality Checks
========================================================================================

## ScriptPurpose:

 --Jus script performs quality checks to validate the integrity, consistency.

--and accuracy of the Gold Layer. These checks ensure:

--Uniqueness of surrogate keys in dimension tables.

--Referential integrity between fact and dimension tables.

--Validation of relationships in the data model for analytical purposes.

## Usage Notes:

--Run these checks after data loading Silver Layer.

--Investigate and resolve any discrepancies found during the checks.
========================================================================================
*/
========================================================================================

## Checking 'gold.dim_customers
========================================================================================

--Check for Uniqueness of Custoner Key in gold.dim customers

## Expectation: No results

 SELECT

        customer key,
        COUNT(*) AS duplicate_count
FROM gold.dim customers

GROUP BY customer key

 HAVING COUNT(*)>1;

=========================================================================================
--Checking 'gold.product_key'
==========================================================================================
Check for Uniqueness of Product Key in gold.dim products.

Expectation: No results

SELECT
    product key,
    COUNT(*) AS duplicate count
FROM gold.dim products
GROUP BY product_key
HAVING COUNT(*)>1;
===========================================================================
 ---Checking 'gold,fact sales
=============================================================================
----Check the data model connectivity between fact and dimensions

 SELECT *
 FROM gold fact sales f

 LEFT JOIN gold.dim_customers c

 ON c.customer keyf.customer key 

 LEFT JOIN gold.dis products p

 ON p.product keyf.product_key

 WHERE p.product key 15 MILL OR c.customer key is NULL
