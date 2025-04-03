{{ config(
    unique_key='sat_customer_type_key',
    merge_update_columns=['hashdiff', 'load_ts', 'customer_desc', 'record_source']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_customer_demographic') }}
),
hub_keys AS (
    SELECT customer_type_id, hub_customer_type_key FROM {{ ref('hub_customer_types') }}
),
prepared AS (
    SELECT
        sd.*,
        {{ dbt_utils.generate_surrogate_key(['sd.customer_desc']) }} AS hashdiff
    FROM source_data sd
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['hk.hub_customer_type_key', 'p.hashdiff']) }} AS sat_customer_type_key,
    hk.hub_customer_type_key,
    p.customer_desc,
    p.hashdiff,
    p.record_source,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts
FROM prepared p
JOIN hub_keys hk ON p.customer_type_id = hk.customer_type_id

{% if is_incremental() %}
WHERE p.hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
