{{ config(
    unique_key='hub_employee_key'
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['employee_id']) }} AS hub_employee_key,
    employee_id,
    CAST(CURRENT_TIMESTAMP AS timestamp (6) with time zone) AS load_ts,
    record_source
FROM {{ ref('stg_employees') }}

{% if is_incremental() %}
WHERE employee_id NOT IN (SELECT employee_id FROM {{ this }})
{% endif %}
