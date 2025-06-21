-- This mart exposes customer sales data from the external Iceberg table in Snowflake.
-- Each row represents a sales line with customer, company, country, revenue, and load timestamp.

SELECT *
FROM {{ source('external_tables', 'mart_customer_sales_external') }}
