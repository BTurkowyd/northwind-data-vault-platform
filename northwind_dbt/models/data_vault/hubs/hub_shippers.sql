{{ config(
    unique_key='hub_shipper_key',
    merge_update_columns=['shipper_id', 'load_ts', 'record_source']
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['shipper_id']) }} AS hub_shipper_key,
    shipper_id,
    CAST(CURRENT_TIMESTAMP AS timestamp (6) with time zone) AS load_ts,
    record_source
FROM {{ ref('stg_shippers') }}

{% if is_incremental() %}
WHERE shipper_id NOT IN (SELECT shipper_id FROM {{ this }})
{% endif %}
