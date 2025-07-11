-- This model creates a hub for products in the Northwind database.
{{ config(
    unique_key='hub_product_key',
    merge_update_columns=['product_id', 'load_ts', 'record_source']
) }}

-- Create a hub for products with a surrogate key for product_id and load timestamp.
SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS hub_product_key,
    product_id,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM {{ ref('stg_products') }}

{% if is_incremental() %}
    WHERE product_id NOT IN (SELECT product_id FROM {{ this }})
{% endif %}
