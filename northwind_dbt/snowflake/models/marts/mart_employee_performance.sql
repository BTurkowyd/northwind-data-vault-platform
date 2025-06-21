-- This mart exposes employee performance metrics from the external Iceberg table in Snowflake.
-- Each row contains an employee, total lines processed, and total revenue generated.

SELECT *
FROM {{ source('external_tables', 'mart_employee_performance_external') }}
