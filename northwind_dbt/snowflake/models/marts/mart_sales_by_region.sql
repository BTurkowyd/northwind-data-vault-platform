-- This mart exposes aggregated sales by region, city, and month from the external Iceberg table in Snowflake.
-- Each row contains region, city,

SELECT *
FROM {{ source('external_tables', 'mart_sales_by_region_external') }}
