-- This model creates a hub for customer types in the Northwind database.
{{ config(
    unique_key='hub_customer_type_key',
    merge_update_columns=['customer_type_id', 'load_ts', 'record_source']
) }}

-- Create a hub for customer types with a surrogate key for customer_type_id and load timestamp.
SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_type_id']) }} AS hub_customer_type_key,
    customer_type_id,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM {{ ref('stg_customer_demographic') }}

{% if is_incremental() %}
    WHERE customer_type_id NOT IN (SELECT customer_type_id FROM {{ this }})
{% endif %}
