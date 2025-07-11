-- This model creates a hub for orders in the Northwind database.
{{ config(
    unique_key='hub_order_key',
    merge_update_columns=['order_id', 'load_ts', 'record_source']
) }}

-- Create a hub for orders with a surrogate key for order_id and load timestamp.
SELECT
    {{ dbt_utils.generate_surrogate_key(['order_id']) }} AS hub_order_key,
    order_id,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM {{ ref('stg_orders') }}

{% if is_incremental() %}
    WHERE order_id NOT IN (SELECT order_id FROM {{ this }})
{% endif %}
