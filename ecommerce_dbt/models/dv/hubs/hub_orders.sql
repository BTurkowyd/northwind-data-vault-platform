{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='hub_order_key',
    table_type='iceberg',
    format='parquet'
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['order_id']) }} AS hub_order_key,
    order_id,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_date,
    record_source
FROM {{ ref('stg_orders') }}

{% if is_incremental() %}
WHERE order_id NOT IN (SELECT order_id FROM {{ this }})
{% endif %}