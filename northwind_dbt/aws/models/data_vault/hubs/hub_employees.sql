-- This model creates a hub for employees in the Northwind database.
{{ config(
    unique_key='hub_employee_key'
) }}

-- Create a hub for employees with a surrogate key for employee_id and load timestamp.
SELECT
    {{ dbt_utils.generate_surrogate_key(['employee_id']) }} AS hub_employee_key,
    employee_id,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM {{ ref('stg_employees') }}

{% if is_incremental() %}
    WHERE employee_id NOT IN (SELECT employee_id FROM {{ this }})
{% endif %}
