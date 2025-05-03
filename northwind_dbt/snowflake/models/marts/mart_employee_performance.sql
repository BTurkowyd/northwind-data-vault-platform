SELECT *
FROM {{ source('external_tables', 'mart_employee_performance_external') }}
