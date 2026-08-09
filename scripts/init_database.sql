/*
===============================================================================
Create Database and Schemas
===============================================================================
Script Purpose:
    This script creates a new database named 'datawarehouse' and sets up
    three schemas within the database: 'bronze', 'silver', and 'gold'.
    The database is intended to support a layered data warehouse architecture,
    where:
        - 'bronze' stores raw source data,
        - 'silver' stores cleaned and transformed data,
        - 'gold' stores business-ready analytical data.
Note:
    This script does not drop or overwrite an existing database.
    If the database already exists, create the schemas inside the existing
    'datawarehouse' database.
===============================================================================
*/


-- Creating database
create database DataWarehouse;


-- Creating schemas
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;