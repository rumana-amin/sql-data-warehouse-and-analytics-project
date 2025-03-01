/* ===========================================================================
             Customer Report
==============================================================================
Purpose:
	- This report consolidates key customer metrics and behaviors
Highlights:
	1. Gathers essentail fields such as names, ages, and transaction details.
	2. Segemnt customer into categories (VIP, Regular, New) and age group.
	3. Aggregate customer-level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. Calculate valuable KPIs:
		-recency (months since last order)
		- average orde value
		-average monthly spend
============================================================================ */

-- ===========================================================================
-- Create Report: gold.report_customers
-- ===========================================================================

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;

GO
 CREATE VIEW gold.report_customers AS 

WITH base_query AS(   ------ 1) Base Query: Retrieves core columns from table
    SELECT
	  f.order_number,
	  f.order_date,
	  f.sales_amount,
	  f.quantity,
	  f.product_key,
	  c.customer_key,
	  c.customer_number,
	  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	  DATEDIFF(year, c.birthday, GETDATE()) AS age
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c
	  ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL)

, customer_aggregation AS(  ---- 2) Customer Aggregations: Summarizes key metrics at the customer level
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age
	)

SELECT                      --------- 3) Final Query
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 and above'
	END AS age_group,
	CASE 
		WHEN lifespan >=12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >=12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment,
	last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) AS recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	-- Compute average order value (AVO)
	CASE WHEN total_orders = 0 THEN 0          
		ELSE total_sales / total_orders
	END AS avg_order_value,
	-- Compute average monthly spend
	CASE WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_spending
FROM customer_aggregation
