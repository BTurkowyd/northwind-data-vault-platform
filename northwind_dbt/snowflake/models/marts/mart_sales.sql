SELECT *
FROM {{ source('external_tables', 'mart_sales_external') }}
