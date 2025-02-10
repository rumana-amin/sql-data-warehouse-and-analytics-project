/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse'. 
    Additionally, the script sets up three schemas within the database: 
    'bronze', 'silver', and 'gold'.
*/

USE master;

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE  DataWarehouse;
GO

--- Create Schemas ----

Create Schema bronze;
GO

Create Schema silver;
GO

Create Schema gold;
GO
