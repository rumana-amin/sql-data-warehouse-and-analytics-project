# sql-data-warehouse-project
Welcome to the Data Warehouse and Analytics Project repository! 🚀  <br>
This guided project demonstrates a data warehousing and analytics solution, from building a data warehouse to generating actionable insights. 

# 🏗️Data Architecture
The data architecture for this project follows Medallion Architecture Bronze, Silver, and Gold layers:
![Data Warehouse Architecture](Docs/1_Data_Architecture.png)

**1.Bronze Layer:** Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database. <br>
**2.Silver Layer:** This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis. <br>
**3.Gold Layer:** Houses business-ready data modeled into a star schema required for reporting and analytics.

# 📖 Project Overview
This project involves:

**Data Architecture:** Designing a Modern Data Warehouse Using Medallion Architecture Bronze, Silver, and Gold layers.  <br>
**ETL Pipelines:** Extracting, transforming, and loading data from source systems into the warehouse.  <br>
**Data Modeling:** Developing fact and dimension tables optimized for analytical queries.  <br>
**Analytics & Reporting:** Creating SQL-based reports and dashboards for actionable insights. <br>

# 🚀 Project Requirements
## Building the Data Warehouse (Data Engineering)
### Objective
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

### Specifications
- **Data Sources:** Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality:** Cleanse and resolve data quality issues prior to analysis.
- **Integration:** Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope:** Focus on the latest dataset only; historization of data is not required.
- **Documentation:** Provide clear documentation of the data model to support both business stakeholders and analytics teams.

# BI: Analytics & Reporting (Data Analysis)
## Objective
Develop SQL-based analytics to deliver detailed insights into:

- **Customer Behavior**
- **Product Performance**
- **Sales Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making.

For more details, refer to docs/requirements.md.

# 📂 Repository Structure

```
sql-data-warehouse-and-analytics-project/
│
├── Datasets/                           # Raw datasets used for the project (ERP and CRM data in csv)
│
├── Docs/                               # Project documentation and architecture details
│   ├── etl.drawio                      # Draw.io file shows all different techniquies and methods of ETL
│   ├── 1_Data_Architecture.png         # PNG file shows the project's architecture
|   ├── 2_Integration_Model.png         
│   ├── Data Catalog.md                 # Catalog of datasets, including field descriptions and metadata
│   ├── 3_Data_Flow_Diagram.png         # PNG file for the data flow diagram
│   ├── 4_Data_mart.png                 # PNG file for data models (star schema)
│
├── Scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Scripts for extracting and loading raw data
│   ├── silver/                         # Scripts for cleaning and transforming data
│   ├── gold/                           # Scripts for creating analytical models
│
├── tests/                              # Test scripts and quality files
|                          
|── EDA & Analysis Scripts/             # SQL scripts for EDA, query analysis and query reports
|   ├──EDA_Analysis.sql                 # EDA analysis like database exploration, dimension exploration, date range exloration etc.
|   ├──Advance_Analysis.sql             # Business analysis like change over time analysis, performance analysis, cumulative analysis etc. 
|   ├──report_customers.sql             # Business report placing importance on customer dimension
|   ├──report_products.sql              # Business report placing importance on product dimension
│
├── README.md                           # Project overview

```

# Original Repository
[Link Here](https://github.com/DataWithBaraa/sql-data-warehouse-project)
