/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
-- Quality Check: A primary key must be unique and not null
SELECT 
	cst_id, COUNT(*)
FROM bronze.crm_cust_info_
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

--- Check for Unwanted Space
--- Expectation: No Results
SELECT 
	cst_firstname
FROM bronze.crm_cust_info_
WHERE cst_firstname != TRIM(cst_firstname)

SELECT 
	cst_lastname
FROM bronze.crm_cust_info_
WHERE cst_lastname != TRIM(cst_lastname)

--- Check the consistency of values in low cardinality columns
--- Data Standardization & Consistency

SELECT DISTINCT 
	cst_gndr
FROM bronze.crm_cust_info_;

-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
	prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted Spaces
-- Expectation: No Results
SELECT
	prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Numbers
-- Expectation: No Results
SELECT 
	prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standarziaztion & Consistency
SELECT DISTINCT
	prd_line
FROM bronze.crm_prd_info;

-- Check for Invalid Date Orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================
-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT 
	NULLIF(sls_ship_dt, 0) sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0          -- Check for Negative numbers or Zero
	OR LEN(sls_ship_dt) != 8    -- Check for length of the date
	OR sls_ship_dt > 20500101 
	OR sls_ship_dt < 19000101;  -- Check for outliers by validating the boundaries of the date range
	

SELECT 
NULLIF(sls_due_dt, 0) sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0			-- Check for Negative numbers or Zero
	OR LEN(sls_due_dt) != 8		-- Check for length of the date
	OR sls_due_dt > 20500101 
	OR sls_due_dt < 19000101;	-- Check for outliers by validating the boundaries of the date range
	
-- Check for Invalid Date Orders(Order Date > Shipping/Due Dates)
SELECT*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
	OR sls_order_dt > sls_due_dt; 

-- Check Data Consistency: Between Sales, Quantity, and Price
-->> Sales = Quantity * Price
-->> Values must not be NULL, Zero or Negative
SELECT DISTINCT 
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity *  sls_price
	OR sls_sales IS NULL 
	OR sls_quantity IS NULL 
	OR sls_price IS NULL
	OR sls_sales <= 0 
	OR sls_quantity <=0 
	OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================
-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
-->> Check for very old customers
-->> Check for birthdays in the future
SELECT DISTINCT
	bdate
FROM bronze.erp_cust_az12
Where bdate < '1925-01-01' 
	OR bdate > GETDATE();

	-- Data Standardization & Consistency
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================
-- Data Standardization & Consistency
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- Check for unwanted spaces
SELECT* 
WHERE cat != TRIM(cat) 
	OR subcat != TRIM(subcat) 
	OR maintenance != TRIM(maintenance)
FROM bronze.erp_px_cat_g1v2

-- Data Standardization & Consistency
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;
