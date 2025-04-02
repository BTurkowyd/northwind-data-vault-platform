{{ config(
    unique_key='link_employee_territory_key'
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_employee_territories') }}
),
hub_employees AS (
    SELECT employee_id, hub_employee_key FROM {{ ref('hub_employees') }}
),
hub_territories AS (
    SELECT territory_id, hub_territory_key FROM {{ ref('hub_territories') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['he.hub_employee_key', 'ht.hub_territory_key']) }} AS link_employee_territory_key,
    he.hub_employee_key,
    ht.hub_territory_key,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts,
    sd.record_source
FROM source_data sd
JOIN hub_employees he ON sd.employee_id = he.employee_id
JOIN hub_territories ht ON sd.territory_id = ht.territory_id

{% if is_incremental() %}
WHERE {{ dbt_utils.generate_surrogate_key(['he.hub_employee_key', 'ht.hub_territory_key']) }}
  NOT IN (SELECT link_employee_territory_key FROM {{ this }})
{% endif %}