-- This satellite table captures the attributes of categories in the Northwind database.
{{ config(
    unique_key='sat_category_key',
    merge_update_columns=['hashdiff', 'category_name', 'description', 'picture', 'load_ts', 'record_source']
) }}

-- The satellite table is built from the staging model 'stg_categories'.
WITH source_data AS (
    SELECT * FROM {{ ref('stg_categories') }}
),

-- The hub table for categories is referenced to get the hub keys.
hub_keys AS (
    SELECT
        category_id,
        hub_category_key
    FROM {{ ref('hub_categories') }}
)

-- The satellite table is constructed by joining the source data with the hub keys.
SELECT
    {{ dbt_utils.generate_surrogate_key(['hk.hub_category_key', 'sd.hashdiff']) }} AS sat_category_key,
    hk.hub_category_key,
    sd.category_name,
    sd.description,
    sd.picture,
    sd.record_source,
    sd.hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts
FROM (
    -- The source data with hashdiff
    SELECT
        *,
        {{ dbt_utils.generate_surrogate_key(['category_name', 'description']) }} AS hashdiff
    FROM source_data
) AS sd
-- Join with the hub keys
INNER JOIN hub_keys AS hk ON sd.category_id = hk.category_id

{% if is_incremental() %}
    WHERE sd.hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
