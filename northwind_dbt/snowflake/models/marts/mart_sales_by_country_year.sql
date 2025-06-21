-- This mart exposes aggregated sales by country and year from the external Iceberg table in Snowflake.
-- Each row contains country, year, total revenue, total freight, and order count.

SELECT *
FROM {{ source('external_tables', 'mart_sales_by_country_year_external') }}
