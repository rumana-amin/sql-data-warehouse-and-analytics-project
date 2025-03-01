       
	 ----------- Exploratory Data Analysis (EDA) --------------------

/* ===============================================================================
    01. Database Exploration
==================================================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
=============================================================================== */

-- Explore All Objects in the Database
SELECT * 
FROM INFORMATION_SCHEMA.TABLES;

--Explore All Columns in the Database
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';


/* ===============================================================================
    02. Dimensions Exploration
==================================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
=============================================================================== */

-- Explore All Countries our customers come from.
SELECT DISTINCT country
FROM gold.dim_customers; 

-- Explore All Categories "The Major Divisions"
SELECT DISTINCT 
    category,
    subcategory, 
    product_name 
FROM gold.dim_products
ORDER BY 1,2,3;


/* ===============================================================================
    03. Date Range Exploration 
=================================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
=============================================================================== */

-- Determine the first and last order date and the total duration in months
SELECT 
    MIN(order_date) first_order_date, 
    MAX(order_date) last_order_date, 
    DATEDIFF(year, MIN(order_date), MAX(order_date)) as order_range_years,
    DATEDIFF(month, MIN(order_date), MAX(order_date)) as order_range_months
FROM gold.fact_sales;

-- Find the youngest and oldest customer based on birthdate
SELECT
    MIN(birthday) AS oldest_customer,
    DATEDIFF(YEAR, MIN(birthday), GETDATE()) AS oldest_age,
    MAX(birthday) AS youngest_customer,
    DATEDIFF(YEAR, MAX(birthday), GETDATE()) AS youngest_age
FROM gold.dim_customers;


/* ===============================================================================
    04. Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
=============================================================================== */

-- Find the Total Sales
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales;

-- Find how many items are sold
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales;

-- Find the average selling price
SELECT AVG(price) AS avg_selling_price FROM gold.fact_sales;

-- Find the Total number of Orders
SELECT COUNT(order_number) AS num_of_orders FROM gold.fact_sales;
SELECT COUNT(DISTINCT order_number) AS num_of_orders FROM gold.fact_sales;

-- Find the total number of products
SELECT COUNT(product_key) AS total_products FROM gold.dim_products;

-- Find the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers;

-- Find the total number of customers that has places an order
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.fact_sales;

-- Generate a Report that shows all key metrics of the  business
-- Tips: UNION: Number of columns and Data Type must be matching
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL 
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products', COUNT(product_key) FROM gold.dim_products
UNION ALL
SELECT 'Total Nr. Customers', COUNT(DISTINCT customer_key) FROM gold.fact_sales;


/* ===============================================================================
    05. Magnitude Analysis
==================================================================================
Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding data distribution across categories.

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
=============================================================================== */

-- Find the Total Customers by country
SELECT 
    country, 
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers 
GROUP BY country
ORDER BY 2 DESC;

-- Find the Total Customers by gender
SELECT
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers 
GROUP BY gender
ORDER BY 2 DESC;

-- Find the Total Products by category
SELECT
    COUNT(product_key) AS total_products,
    category
FROM gold.dim_products
GROUP BY category
ORDER BY 1 DESC;

-- What is the average costs in each category?
SELECT 
    category,
    AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY 2 DESC;

-- What is the total revenue generated in each category?
SELECT 
    p.category, 
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
INNER JOIN gold.dim_products AS p
    ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY 2 DESC;

-- What is the total revenue generated by each customer?
SELECT 
    c.customer_id,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
INNER JOIN gold.dim_customers AS c 
    ON s.customer_key = c.customer_key
GROUP BY c.customer_id
ORDER BY 2 DESC;

-- What is the distribution of sold items across countries?
SELECT 
c.country,
    SUM(s.quantity) AS total_sold_items
    FROM gold.fact_sales AS s
INNER JOIN gold.dim_customers AS c 
    ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY 2 DESC;

--TIP- Low Cardinality Dimesnsion: Dimesion with few unique values (e.g., gender, marital_status...)


/* ===============================================================================
    06. Ranking Analysis
==================================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
=============================================================================== */

-- Which 5 products generate the highest revenue?
-- Simple Ranking
SELECT TOP(5) 
    p.product_name,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
INNER JOIN gold.dim_products AS p 
    ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY 2 DESC;

-- Complex but Flexibly Ranking Using Window Functions
SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS ranked_products
WHERE rank_products <= 5;

-- What are the 5 worst performing products in terms of sales?
SELECT TOP(5) 
    p.product_name,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
INNER JOIN gold.dim_products AS p
    ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY 2;

-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
WHERE c.customer_key IS NOT NULL
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- The 3 customers with the fewest orders placed
SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders ;

