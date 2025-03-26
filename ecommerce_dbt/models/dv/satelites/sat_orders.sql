{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='sat_order_key',
    merge_update_columns=['hashdiff', 'load_ts', 'total_amount', 'status']
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['order_id', dbt_utils.generate_surrogate_key(['total_amount', 'status']) ]) }} AS sat_order_key,
    order_id,
    total_amount,
    status,
    {{ dbt_utils.generate_surrogate_key(['total_amount', 'status']) }} AS hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts
FROM {{ ref('stg_orders') }}

{% if is_incremental() %}
WHERE {{ dbt_utils.generate_surrogate_key(['total_amount', 'status']) }}
    NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}