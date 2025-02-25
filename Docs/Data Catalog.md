# Data Catalog for Gold Layer
## Overview
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of dimension tables and fact table for specific business metrics.
### 1. gold.dim_customers  
- **Purpose:** Stores customer details enriched with demographic and geographic data.  
- **Columns:**

| Column Name      | Data Type     | Description |
|-----------------|--------------|--------------------------------------------------------------|
| customer_key    | INT          | Surrogate key uniquely identifying each customer record. |
| customer_id     | INT          | Unique numerical identifier assigned to each customer. |
| customer_number | NVARCHAR(50) | Alphanumeric identifier used for tracking and referencing. |
| first_name      | NVARCHAR(50) | The customer’s first name. |
| last_name       | NVARCHAR(50) | The customer’s last name. |
| country         | NVARCHAR(50) | Country of residence (e.g., Australia). |
| marital_status  | NVARCHAR(50) | Marital status (e.g., 'Married', 'Single'). |
| gender          | NVARCHAR(50) | Gender (e.g., 'Male', 'Female', 'n/a'). |
| birthdate       | DATE         | Date of birth (YYYY-MM-DD, e.g., 1971-10-06). |
| create_date     | DATE         | Date when the customer record was created. |


### 2. gold.dim_products
- **Purpose:** Provides information about the products and their attributes.
- **Columns:**

| Column Name            | Data Type     | Description |
|------------------------|--------------|--------------------------------------------------------------|
| product_key           | INT          | Surrogate key uniquely identifying each product record. |
| product_id            | INT          | Unique numerical identifier assigned to the product. |
| product_number        | NVARCHAR(50) | Alphanumeric code representing the product for categorization. |
| product_name          | NVARCHAR(50) | Descriptive name including key details like type, color, and size. |
| category_id          | NVARCHAR(50) | Unique identifier linking the product to its category. |
| category             | NVARCHAR(50) | Broader classification of the product (e.g., Bikes, Components). |
| subcategory         | NVARCHAR(50) | More detailed classification within the category. |
| maintenance_required | NVARCHAR(50) | Indicates if maintenance is needed (e.g., 'Yes', 'No'). |
| cost                 | INT          | Base price of the product in monetary units. |
| product_line         | NVARCHAR(50) | Specific product line or series (e.g., Road, Mountain). |
| start_date          | DATE         | Date when the product became available for sale or use. |

### 3. gold.fact_sales
- **Purpose:** Stores transactional sales data for analytical purpose.
-	**Columns:**

| Column Name     | Data Type     | Description |
|----------------|--------------|--------------------------------------------------------------|
| order_number   | NVARCHAR(50) | Unique alphanumeric identifier for each sales order (e.g., ‘SO54496’). |
| product_key    | INT          | Surrogate key linking the order to the product dimension table. |
| customer_key   | INT          | Surrogate key linking the order to the customer dimension table. |
| order_date     | DATE         | The date when the order was placed. |
| shipping_date  | DATE         | The date when the order was shipped to the customer. |
| due_date       | DATE         | The date when the order payment was due. |
| sales_amount   | INT          | Total monetary value of the sale for the line item (e.g., 25). |
| quantity       | INT          | Number of units of the product ordered for the line item (e.g., 1). |
| price          | INT          | Price per unit of the product for the line item (e.g., 25). |

