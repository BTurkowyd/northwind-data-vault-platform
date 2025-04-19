-- Switch to the highest-privileged role to perform admin-level tasks
USE ROLE role_with_privileges;

-- Set the context to the appropriate compute resources and database
USE WAREHOUSE NORTHWIND_WH_DEV;
USE DATABASE NORTHWIND_DB_DEV;
USE SCHEMA NORTHWIND_SCHEMA_DEV;

-- Set the 'pii' tag to 'true' on the 'company_name' column
ALTER TABLE NORTHWIND_DB_DEV.NORTHWIND_SCHEMA_DEV.MART_CUSTOMER_SALES
  MODIFY COLUMN company_name
  SET TAG "pii" = 'true';

-- Set the 'pii' tag to 'true' on the 'hub_customer_key' column
ALTER TABLE NORTHWIND_DB_DEV.NORTHWIND_SCHEMA_DEV.MART_CUSTOMER_SALES
  MODIFY COLUMN hub_customer_key
  SET TAG "pii" = 'true';

-- Apply masking policy to the 'company_name' column in the MART_CUSTOMER_SALES table
-- This ensures sensitive data is redacted based on the masking policy logic
ALTER TABLE NORTHWIND_DB_DEV.NORTHWIND_SCHEMA_DEV.MART_CUSTOMER_SALES
MODIFY COLUMN company_name
SET MASKING POLICY redact_varchar;

-- Apply the same masking policy to 'hub_customer_key' column
ALTER TABLE NORTHWIND_DB_DEV.NORTHWIND_SCHEMA_DEV.MART_CUSTOMER_SALES
MODIFY COLUMN hub_customer_key
SET MASKING POLICY redact_varchar;

-- Switch to a lower-privileged role (e.g., business user role) to test data access
USE ROLE NORTHWIND_OWNER_DEV;

-- Execute a sample query to see how masked columns appear for this role
SELECT * FROM mart_customer_sales ORDER BY revenue DESC;

-- Switch back to admin role (if needed) to remove the masking policies
USE ROLE role_with_privileges;

-- Remove the masking policy from 'company_name' column
ALTER TABLE NORTHWIND_DB_DEV.NORTHWIND_SCHEMA_DEV.MART_CUSTOMER_SALES
  MODIFY COLUMN company_name
  UNSET MASKING POLICY;

-- Remove the masking policy from 'hub_customer_key' column
ALTER TABLE NORTHWIND_DB_DEV.NORTHWIND_SCHEMA_DEV.MART_CUSTOMER_SALES
  MODIFY COLUMN hub_customer_key
  UNSET MASKING POLICY;
