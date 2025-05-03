SELECT *
FROM {{ source('external_tables', 'mart_customer_sales_external') }}
