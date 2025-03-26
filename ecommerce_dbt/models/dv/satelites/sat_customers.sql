{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='sat_customer_key',
    merge_update_columns=['hashdiff', 'load_ts', 'name', 'email']
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_id', dbt_utils.generate_surrogate_key(['name', 'email']) ]) }} AS sat_customer_key,
    customer_id,
    name,
    email,
    {{ dbt_utils.generate_surrogate_key(['name', 'email']) }} AS hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts

FROM {{ ref('stg_customers') }}

{% if is_incremental() %}
WHERE {{ dbt_utils.generate_surrogate_key(['name', 'email']) }} NOT IN (
    SELECT hashdiff FROM {{ this }}
)
{% endif %}