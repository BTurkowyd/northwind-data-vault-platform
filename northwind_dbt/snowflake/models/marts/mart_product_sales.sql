-- This mart exposes product sales metrics from the external Iceberg table in Snowflake.
-- Each row contains a product, total orders, total quantity sold, and total revenue.

SELECT *
FROM {{ source('external_tables', 'mart_product_sales_external') }}
