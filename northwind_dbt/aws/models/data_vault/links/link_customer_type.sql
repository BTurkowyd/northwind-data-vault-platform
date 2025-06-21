-- This link table connects customers to their types in the Northwind database.
{{ config(
    unique_key='link_customer_type_key',
    merge_update_columns=['hub_customer_key', 'hub_customer_type_key', 'load_ts', 'record_source']
) }}

-- The link table is built from the staging model 'stg_customer_customer_demo',
WITH source_data AS (
    SELECT * FROM {{ ref('stg_customer_customer_demo') }}
),

-- The hub tables for customers and customer types are referenced to get their keys.
hub_customers AS (
    SELECT
        customer_id,
        hub_customer_key
    FROM {{ ref('hub_customer_customer_demo') }}
),

-- The hub table for customer types is referenced to get their keys.
hub_customer_types AS (
    SELECT
        customer_type_id,
        hub_customer_type_key
    FROM {{ ref('hub_customer_types') }}
)

-- The link table is constructed by joining the source data with the hub tables.
-- It generates a surrogate key for the link and includes load timestamp and record source.
-- Joins are made on customer_id and customer_type_id to get the corresponding keys.
SELECT
    {{ dbt_utils.generate_surrogate_key(['hc.hub_customer_key', 'hct.hub_customer_type_key']) }} AS link_customer_type_key,
    hc.hub_customer_key,
    hct.hub_customer_type_key,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    sd.record_source
FROM source_data AS sd
INNER JOIN hub_customers AS hc ON sd.customer_id = hc.customer_id
INNER JOIN hub_customer_types AS hct ON sd.customer_type_id = hct.customer_type_id

{% if is_incremental() %}
    WHERE
        {{ dbt_utils.generate_surrogate_key(['hc.hub_customer_key', 'hct.hub_customer_type_key']) }}
        NOT IN (SELECT link_customer_type_key FROM {{ this }})
{% endif %}
