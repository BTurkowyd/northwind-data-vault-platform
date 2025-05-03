SELECT *
FROM {{ source('external_tables', 'mart_sales_by_country_year_external') }}
