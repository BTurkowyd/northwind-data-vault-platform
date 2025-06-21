-- This satellite table captures the attributes of employees in the Northwind database.
{{ config(
    unique_key='sat_employee_key',
    merge_update_columns=[
        'hashdiff', 'load_ts', 'last_name', 'first_name', 'title', 'title_of_courtesy',
        'birth_date', 'hire_date', 'address', 'city', 'region', 'postal_code',
        'country', 'home_phone', 'extension', 'photo', 'notes', 'reports_to', 'photo_path'
    ]
) }}

-- The satellite table is built from the staging model 'stg_employees'.
WITH source_data AS (
    SELECT * FROM {{ ref('stg_employees') }}
),

-- The hub table for employees is referenced to get the hub keys.
hub_keys AS (
    SELECT
        employee_id,
        hub_employee_key
    FROM {{ ref('hub_employees') }}
),

-- The satellite table is constructed by joining the source data with the hub keys.
prepared AS (
    SELECT
        sd.*,
        hk.hub_employee_key,
        {{ dbt_utils.generate_surrogate_key([
            'sd.last_name',
            'sd.first_name',
            'sd.title',
            'sd.title_of_courtesy',
            'sd.birth_date',
            'sd.hire_date',
            'sd.address',
            'sd.city',
            'sd.region',
            'sd.postal_code',
            'sd.country',
            'sd.home_phone',
            'sd.extension',
            'sd.notes',
            'sd.reports_to',
            'sd.photo_path'
        ]) }} AS hashdiff
    FROM source_data AS sd
    INNER JOIN hub_keys AS hk ON sd.employee_id = hk.employee_id
)

-- Final selection of attributes for the satellite table.
SELECT
    {{ dbt_utils.generate_surrogate_key(['hub_employee_key', 'hashdiff']) }} AS sat_employee_key,
    hub_employee_key,
    last_name,
    first_name,
    title,
    title_of_courtesy,
    birth_date,
    hire_date,
    address,
    city,
    region,
    postal_code,
    country,
    home_phone,
    extension,
    photo,
    notes,
    reports_to,
    photo_path,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
    WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
