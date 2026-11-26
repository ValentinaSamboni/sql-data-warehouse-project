/*
=================================================================================
Quality Checks
=================================================================================
Script Purpose:
  This script performs various quality checks for data consistency, accuracy,
  and standardization across the 'silver' schemas. It includes checks for:
- Null or duplicated primary keys.
- Unwanted spaces in string fields.
- Data standardization and consistency.
- Invalid date ranges and orders.
- Data consistency between related fields.

Usage notes:
-Run these checks after data loading Silver Layer.
- Investigate and resolve any discrepancies found during the checks.
=================================================================================
*/
-- Check for nulls or duplicates in the primary key
-- Expectation: No results

SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces
-- Expectation: No results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check fro NULLs or negative numbers
-- Expectition: No resulta
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE  prd_cost < 0 OR prd_cost IS NULL

-- Data standariztion & consistncy
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

-- Check for invalid date orders
SELECT * 
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT
prd_id,
prd_key,
prd_nm,
prd_start_dt,
prd_end_dt,
LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')

SELECT *
FROM silver.crm_prd_info

-- Bronze sales details check queries
SELECT *
FROM bronze.crm_sales_details

-- Check for unwanted spaces
SELECT
*
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Comparing values with crm_prd_info from silver layer
SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM  silver.crm_prd_info)

-- Comparing values with crm_cust_info from silver layer
SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM  silver.crm_cust_info)

-- Check and convert datatypes
-- First check fro invalit dates
SELECT 
NULLIF(sls_due_dt, 0) sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt = 0 
OR LEN(sls_due_dt) != 8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101

-- Check for invalid date orders
SELECT 
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check data consistency: between sales, quantitu, and price
-- >>Sales = quantity * Price
-- >> Values must not be NULL, zero or negative

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR  sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0

SELECT * FROM silver.crm_sales_details

-- Cleaning data to conect bronze.erp_cust_az12 >> silver.erp_cust_az12
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE cid
END cid,
CASE WHEN bdate > GETDATE() THEN NULL
	ELSE bdate
END AS bdate,
CASE WHEN UPPER(TRIM (gen)) IN ('F', 'FEMALE') THEN 'Female'
	WHEN UPPER(TRIM (gen)) IN ('m', 'MALE') THEN 'Male'
	ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12;

SELECT * FROM silver.crm_cust_info;

-- Identify out-of-range dates
SELECT DISTINCT
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data standarization & consistency
SELECT DISTINCT
gen, 
CASE WHEN UPPER(TRIM (gen)) IN ('F', 'FEMALE') THEN 'Female'
	WHEN UPPER(TRIM (gen)) IN ('m', 'MALE') THEN 'Male'
	ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12

-- Cleaning data to connect bronze.erp_loc_a101 >> silver.erp_loc_az12
SELECT 
REPLACE(cid, '-', '') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	WHEN TRIM(cntry) = '' OR cntry IS NULL then 'n/a'
	ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101

-- Data standarization & consistency
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
ORDER BY cntry

-- Cleaning data to connect bronze.erp_px_cat_g1v2 >> silver.erp_px_cat_g1v2 
SELECT 
id,
cat,
subcat,
maintanance
FROM bronze.erp_px_cat_g1v2 

-- Check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2 
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standarization & Consistency
SELECT DISTINCT
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2 
