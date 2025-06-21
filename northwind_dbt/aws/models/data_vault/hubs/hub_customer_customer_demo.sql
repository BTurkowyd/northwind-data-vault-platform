-- This model creates a hub for customers in the Northwind database.
{{ config(
    unique_key='hub_customer_key'
) }}


-- Create a hub for customers with a surrogate key for customer_id and load timestamp.
SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} AS hub_customer_key,
    customer_id,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM {{ ref('stg_customer_customer_demo') }}

{% if is_incremental() %}
    WHERE customer_id NOT IN (SELECT customer_id FROM {{ this }})
{% endif %}
