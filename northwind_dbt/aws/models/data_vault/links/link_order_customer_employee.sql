-- This model creates a link table that connects orders, customers, and employees.
{{ config(
    unique_key='link_order_cust_emp_key'
) }}

-- The link table is built from the staging model 'stg_orders',
WITH source_data AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

-- The hub table for orders is referenced to get their keys.
hub_orders AS (
    SELECT
        order_id,
        hub_order_key
    FROM {{ ref('hub_orders') }}
),

-- The hub table for customers is referenced to get their keys.
hub_customers AS (
    SELECT
        customer_id,
        hub_customer_key
    FROM {{ ref('hub_customers') }}
),

-- The hub tables for employees is referenced to get their keys.
hub_employees AS (
    SELECT
        employee_id,
        hub_employee_key
    FROM {{ ref('hub_employees') }}
)

-- The link table is constructed by joining the source data with the hub tables.
-- It generates a surrogate key for the link and includes load timestamp and record source.
-- Joins are made on order_id, customer_id, and employee_id to get the corresponding keys.
SELECT
    {{ dbt_utils.generate_surrogate_key(['ho.hub_order_key', 'hc.hub_customer_key', 'he.hub_employee_key']) }} AS link_order_cust_emp_key,
    ho.hub_order_key,
    hc.hub_customer_key,
    he.hub_employee_key,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    sd.record_source
FROM source_data AS sd
INNER JOIN hub_orders AS ho ON sd.order_id = ho.order_id
INNER JOIN hub_customers AS hc ON sd.customer_id = hc.customer_id
INNER JOIN hub_employees AS he ON sd.employee_id = he.employee_id

{% if is_incremental() %}
    WHERE
        {{ dbt_utils.generate_surrogate_key(['ho.hub_order_key', 'hc.hub_customer_key', 'he.hub_employee_key']) }}
        NOT IN (SELECT link_order_cust_emp_key FROM {{ this }})
{% endif %}
