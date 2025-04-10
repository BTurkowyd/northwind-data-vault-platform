{{ config(
    unique_key='hub_supplier_key',
    merge_update_columns=['supplier_id', 'load_ts', 'record_source']
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['supplier_id']) }} AS hub_supplier_key,
    supplier_id,
    CAST(CURRENT_TIMESTAMP AS timestamp) AS load_ts,
    record_source
FROM {{ ref('stg_suppliers') }}

{% if is_incremental() %}
WHERE supplier_id NOT IN (SELECT supplier_id FROM {{ this }})
{% endif %}
