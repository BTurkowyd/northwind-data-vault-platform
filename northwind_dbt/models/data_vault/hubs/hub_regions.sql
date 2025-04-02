{{ config(
    unique_key='hub_region_key',
    merge_update_columns=['region_id', 'load_ts', 'record_source']
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['region_id']) }} AS hub_region_key,
    region_id,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts,
    record_source
FROM {{ ref('stg_region') }}

{% if is_incremental() %}
WHERE region_id NOT IN (SELECT region_id FROM {{ this }})
{% endif %}