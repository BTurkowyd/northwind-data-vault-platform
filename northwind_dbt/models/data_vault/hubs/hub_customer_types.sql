{{ config(
    unique_key='hub_customer_type_key',
    merge_update_columns=['customer_type_id', 'load_ts', 'record_source']
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_type_id']) }} AS hub_customer_type_key,
    customer_type_id,
    CAST(CURRENT_TIMESTAMP AS timestamp) AS load_ts,
    record_source
FROM {{ ref('stg_customer_demographic') }}

{% if is_incremental() %}
WHERE customer_type_id NOT IN (SELECT customer_type_id FROM {{ this }})
{% endif %}
