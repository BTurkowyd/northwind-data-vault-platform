{{ config(
    unique_key='hub_order_key',
    merge_update_columns=['order_id', 'load_ts', 'record_source']
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['order_id']) }} AS hub_order_key,
    order_id,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts,
    record_source
FROM {{ ref('stg_orders') }}

{% if is_incremental() %}
WHERE order_id NOT IN (SELECT order_id FROM {{ this }})
{% endif %}