{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='link_customer_type_key',
    merge_update_columns=['hub_customer_key', 'hub_customer_type_key', 'load_ts', 'record_source']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_customer_customer_demo') }}
),
hub_customers AS (
    SELECT customer_id, hub_customer_key FROM {{ ref('hub_customer_customer_demo') }}
),
hub_customer_types AS (
    SELECT customer_type_id, hub_customer_type_key FROM {{ ref('hub_customer_types') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['hc.hub_customer_key', 'hct.hub_customer_type_key']) }} AS link_customer_type_key,
    hc.hub_customer_key,
    hct.hub_customer_type_key,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts,
    sd.record_source
FROM source_data sd
JOIN hub_customers hc ON sd.customer_id = hc.customer_id
JOIN hub_customer_types hct ON sd.customer_type_id = hct.customer_type_id

{% if is_incremental() %}
WHERE {{ dbt_utils.generate_surrogate_key(['hc.hub_customer_key', 'hct.hub_customer_type_key']) }}
  NOT IN (SELECT link_customer_type_key FROM {{ this }})
{% endif %}