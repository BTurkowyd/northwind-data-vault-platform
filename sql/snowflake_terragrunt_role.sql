-- Create the role if it doesn't exist
CREATE ROLE IF NOT EXISTS terragrunt_role;

-- Global account-level privileges
GRANT CREATE DATABASE        ON ACCOUNT TO ROLE terragrunt_role;
GRANT CREATE WAREHOUSE       ON ACCOUNT TO ROLE terragrunt_role;
GRANT CREATE ROLE            ON ACCOUNT TO ROLE terragrunt_role;
GRANT APPLY MASKING POLICY   ON ACCOUNT TO ROLE terragrunt_role;
GRANT CREATE INTEGRATION     ON ACCOUNT TO ROLE terragrunt_role;

-- Create the user if it doesn't exist
CREATE USER IF NOT EXISTS github_ci_user
  PASSWORD = 'REDACTED' -- only for initial setup
  RSA_PUBLIC_KEY = 'REDACTED' -- generate it locally and paste it here
  DEFAULT_ROLE = terragrunt_role
  DEFAULT_WAREHOUSE = 'REDACTED'; -- choose a warehouse

ALTER USER github_ci_user UNSET PASSWORD;

-- Grant role to Terraform user
GRANT ROLE terragrunt_role TO USER github_ci_user;

GRANT USAGE ON DATABASE NORTHWIND_DB_DEV TO ROLE terragrunt_role;
GRANT USAGE ON SCHEMA NORTHWIND_DB_DEV.NORTHWIND_SCHEMA_DEV TO ROLE terragrunt_role;
GRANT USAGE ON STAGE NORTHWIND_DB_DEV.NORTHWIND_SCHEMA_DEV.S3_STAGE_DEV TO ROLE terragrunt_role;
