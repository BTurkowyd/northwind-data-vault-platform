{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='hub_product_key',
    table_type='iceberg',
    format='parquet'
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS hub_product_key,
    product_id,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_date,
    record_source
FROM {{ ref('stg_products') }}

{% if is_incremental() %}
WHERE product_id NOT IN (SELECT product_id FROM {{ this }})
{% endif %}