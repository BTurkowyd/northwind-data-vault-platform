{{ config(
    unique_key='link_order_cust_emp_key'
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

hub_orders AS (
    SELECT
        order_id,
        hub_order_key
    FROM {{ ref('hub_orders') }}
),

hub_customers AS (
    SELECT
        customer_id,
        hub_customer_key
    FROM {{ ref('hub_customers') }}
),

hub_employees AS (
    SELECT
        employee_id,
        hub_employee_key
    FROM {{ ref('hub_employees') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['ho.hub_order_key', 'hc.hub_customer_key', 'he.hub_employee_key']) }} AS link_order_cust_emp_key,
    ho.hub_order_key,
    hc.hub_customer_key,
    he.hub_employee_key,
    CAST(CURRENT_TIMESTAMP AS timestamp) AS load_ts,
    sd.record_source
FROM source_data AS sd
INNER JOIN hub_orders AS ho ON sd.order_id = ho.order_id
INNER JOIN hub_customers AS hc ON sd.customer_id = hc.customer_id
INNER JOIN hub_employees AS he ON sd.employee_id = he.employee_id

{% if is_incremental() %}
WHERE {{ dbt_utils.generate_surrogate_key(['ho.hub_order_key', 'hc.hub_customer_key', 'he.hub_employee_key']) }}
  NOT IN (SELECT link_order_cust_emp_key FROM {{ this }})
{% endif %}
