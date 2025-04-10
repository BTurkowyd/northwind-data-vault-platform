{{ config(
    unique_key='hub_product_key',
    merge_update_columns=['product_id', 'load_ts', 'record_source']
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS hub_product_key,
    product_id,
    CAST(CURRENT_TIMESTAMP AS timestamp) AS load_ts,
    record_source
FROM {{ ref('stg_products') }}

{% if is_incremental() %}
WHERE product_id NOT IN (SELECT product_id FROM {{ this }})
{% endif %}
