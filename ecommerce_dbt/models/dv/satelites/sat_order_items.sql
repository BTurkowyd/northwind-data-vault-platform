{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='sat_order_item_key',
    merge_update_columns=['hashdiff', 'load_ts', 'quantity', 'price']
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['item_id', dbt_utils.generate_surrogate_key(['quantity', 'price']) ]) }} AS sat_order_item_key,
    item_id,
    quantity,
    price,
    {{ dbt_utils.generate_surrogate_key(['quantity', 'price']) }} AS hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts
FROM {{ ref('stg_order_items') }}

{% if is_incremental() %}
WHERE {{ dbt_utils.generate_surrogate_key(['quantity', 'price']) }}
    NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}