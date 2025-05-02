{{ config(
    post_hook=apply_column_tags()
) }}

SELECT *
FROM {{ source('external_tables', 'mart_sales_by_country_year_external') }}
