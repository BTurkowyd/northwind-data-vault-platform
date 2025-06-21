-- This link table connects employees to their territories in the Northwind database.
{{ config(
    unique_key='link_employee_territory_key'
) }}

-- The link table is built from the staging model 'stg_employee_territories',
WITH source_data AS (
    SELECT * FROM {{ ref('stg_employee_territories') }}
),

-- The hub table for employees is referenced to get their keys.
hub_employees AS (
    SELECT
        employee_id,
        hub_employee_key
    FROM {{ ref('hub_employees') }}
),

-- The hub table for territories is referenced to get their keys.
hub_territories AS (
    SELECT
        territory_id,
        hub_territory_key
    FROM {{ ref('hub_territories') }}
)

-- The link table is constructed by joining the source data with the hub tables.
-- It generates a surrogate key for the link and includes load timestamp and record source.
-- Joins are made on employee_id and territory_id to get the corresponding keys.
SELECT
    {{ dbt_utils.generate_surrogate_key(['he.hub_employee_key', 'ht.hub_territory_key']) }} AS link_employee_territory_key,
    he.hub_employee_key,
    ht.hub_territory_key,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    sd.record_source
FROM source_data AS sd
INNER JOIN hub_employees AS he ON sd.employee_id = he.employee_id
INNER JOIN hub_territories AS ht ON sd.territory_id = ht.territory_id

{% if is_incremental() %}
    WHERE
        {{ dbt_utils.generate_surrogate_key(['he.hub_employee_key', 'ht.hub_territory_key']) }}
        NOT IN (SELECT link_employee_territory_key FROM {{ this }})
{% endif %}
