{{ config(
    unique_key='sat_shipper_key',
    merge_update_columns=['company_name', 'phone', 'hashdiff', 'load_ts', 'record_source']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_shippers') }}
),

hub_keys AS (
    SELECT
        shipper_id,
        hub_shipper_key
    FROM {{ ref('hub_shippers') }}
),

prepared AS (
    SELECT
        sd.*,
        hk.hub_shipper_key,
        {{ dbt_utils.generate_surrogate_key(['sd.company_name', 'sd.phone']) }} AS hashdiff
    FROM source_data AS sd
    INNER JOIN hub_keys AS hk ON sd.shipper_id = hk.shipper_id
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['hub_shipper_key', 'hashdiff']) }} AS sat_shipper_key,
    hub_shipper_key,
    company_name,
    phone,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
    WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
