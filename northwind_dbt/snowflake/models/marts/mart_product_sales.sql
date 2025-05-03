SELECT *
FROM {{ source('external_tables', 'mart_product_sales_external') }}
