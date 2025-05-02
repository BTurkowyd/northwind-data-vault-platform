{{ config(
    post_hook=apply_column_tags()
) }}

SELECT *
FROM {{ source('external_tables', 'mart_sales_by_region_external') }}
