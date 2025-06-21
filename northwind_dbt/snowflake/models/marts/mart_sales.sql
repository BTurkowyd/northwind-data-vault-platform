-- This mart exposes detailed sales facts from the external Iceberg table in Snowflake.
-- Each row represents an order-product line with revenue, shipment, and order details.

SELECT *
FROM {{ source('external_tables', 'mart_sales_external') }}
