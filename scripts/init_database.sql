/*
=========================================
CREATE DATABASE AND SCHEMAS
=========================================
Script Purpose:
  This script creates a new database named 'DataWarehouse' after checking if already exists.
  If the database exist, it is dropped and recreated. Additionally, the script sets up three schemas
  within the database: 'broze', 'silver', and 'gold'.

WARNING
  Running this scrip will drop the entire 'DataWarehouse' data base if it exists.
  All data in the database will be permanently deleted. Proceed with caution and 
  ensure you have proper backups before running this script.
*/

-- Create Database 'DataWarehouse'

USE master;
GO

-- Drop and recreate the 'DataWarehouse' data base
IF EXIST (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
  ALTER DATA DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE DataWarehouse;
END;
GO
  
CREATE DATABASE DataWarehouse;
GO
  
USE DataWarehouse;
GO

-- Create SCHEMAS
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
