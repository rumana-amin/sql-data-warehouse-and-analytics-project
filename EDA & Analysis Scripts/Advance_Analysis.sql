
       ---------- Advanced Analytics: SQL Queries ------------

/* ===============================================================================
    01. Change Over Time Analysis
==================================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
=============================================================================== */

-- Analyse sales performance over time
SELECT 
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT (DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

-- Quick Date Functions
SELECT 
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT (DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

-- DATETRUNC()
SELECT 
    DATETRUNC(MONTH, order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT (DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date);

-- FORMAT()
SELECT 
    FORMAT (order_date, 'yyyy-MMM') AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT (DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT (order_date, 'yyyy-MMM') 
ORDER BY FORMAT (order_date, 'yyyy-MMM');


/* ===============================================================================
    02. Cumulative Analysis
==================================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
=============================================================================== */
-- Calculate the total sales per month and the running total sales over time
-- Moving Average of Sales by Month

SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
	(
	SELECT
	DATETRUNC(month, order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(month, order_date)
	) t ;


/* ===============================================================================
    03. Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
=============================================================================== */

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */ 
WITH yearly_product_sales AS (
    SELECT
	  YEAR(f.order_date) AS order_year,
	  p.product_name,
	  SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
	  ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
	  YEAR(f.order_date),
	  p.product_name
)

SELECT 
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE
	    WHEN AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
	    WHEN AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
	    ELSE 'Avg'
    END AS avg_change,
    LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE
	    WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	    WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	    ELSE 'No Change'
    END  AS py_chage
FROM yearly_product_sales
ORDER BY 2,1 ;


/* ===============================================================================
    04. Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
=============================================================================== */
--Which categories contribute the most to overall sales?
WITH category_sales AS (
    SELECT
	  category,
	  SUM(sales_amount) AS total_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
	  ON p.product_key = f.product_key
    GROUP BY category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () overall_sales,
    CONCAT(ROUND((CAST(total_sales AS float) / SUM(total_sales) OVER ()) *100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;


/* ===============================================================================
    05. Data Segmentation Analysis
==================================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
    -CTE & SUBQUERY:
=============================================================================== */
-- Segment products into cost range and count how many products fall into each segment.
WITH product_segment AS (
    SELECT 
	  product_key,
	  product_name
	  cost,
	  CASE WHEN cost < 100 THEN 'Below 100'
		  WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		  WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		  ELSE 'Above 1000'
	  END AS cost_range
    FROM gold.dim_products
)
SELECT
    cost_range,
    COUNT(product_key) AS total_product
FROM product_segment
GROUP BY cost_range
ORDER BY total_product DESC;

/* Group customers into three segments based on their spending behavior:
- VIP: Customers with at least 12 months of history and spending more then $5,000.
- Regular: Customers with at least 12 months of history but spending $5,000 or less.
- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

WITH customer_segment AS (
    SELECT
	  c.customer_key,
	  SUM(f.sales_amount) AS total_sales,
	  MIN(f.order_date) AS first_order,
	  MAX(f.order_date) AS last_order,
	  DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c
	  ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT
    customer_group,
    COUNT(customer_key) AS total_customer
FROM
	(SELECT 
	    customer_key,
	    total_sales,
	    CASE 
		    WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		    WHEN lifespan >= 12 AND total_sales < 5000 THEN 'Regular'
		    ELSE 'New'
	    END AS customer_group
	From customer_segment) t
GROUP BY customer_group
ORDER BY total_customer DESC;
