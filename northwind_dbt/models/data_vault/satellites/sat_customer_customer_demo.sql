{{ config(
    unique_key='sat_customer_key',
    merge_update_columns=['hashdiff', 'load_ts']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_customer_customer_demo') }}
),

hub_keys AS (
    SELECT
        customer_id,
        hub_customer_key
    FROM {{ ref('hub_customer_customer_demo') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['hk.hub_customer_key', 'sd.record_source']) }} AS sat_customer_key,
    hk.hub_customer_key,
    {{ dbt_utils.generate_surrogate_key(['sd.record_source']) }} AS hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    sd.record_source
FROM source_data AS sd
INNER JOIN hub_keys AS hk ON sd.customer_id = hk.customer_id

{% if is_incremental() %}
    WHERE {{ dbt_utils.generate_surrogate_key(['sd.record_source']) }} NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
