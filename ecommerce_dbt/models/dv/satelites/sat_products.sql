{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='sat_product_key',
    merge_update_columns=['hashdiff', 'load_ts', 'name', 'category', 'price']
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id', dbt_utils.generate_surrogate_key(['name', 'category', 'price']) ]) }} AS sat_product_key,
    product_id,
    name,
    category,
    price,
    {{ dbt_utils.generate_surrogate_key(['name', 'category', 'price']) }} AS hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts
FROM {{ ref('stg_products') }}

{% if is_incremental() %}
WHERE {{ dbt_utils.generate_surrogate_key(['name', 'category', 'price']) }}
    NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}