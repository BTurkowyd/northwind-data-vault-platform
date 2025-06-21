-- This satellite table captures the attributes of customers in the Northwind database.
{{ config(
    unique_key='sat_customer_key',
    merge_update_columns=['hashdiff', 'load_ts', 'company_name', 'contact_name', 'contact_title', 'address', 'city', 'region', 'postal_code', 'country', 'phone', 'fax']
) }}

-- The satellite table is built from the staging model 'stg_customers'.
WITH source_data AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

-- The hub table for customers is referenced to get the hub keys.
hub_keys AS (
    SELECT
        customer_id,
        hub_customer_key
    FROM {{ ref('hub_customers') }}
),

-- The satellite table is constructed by joining the source data with the hub keys.
prepared AS (
    SELECT
        sd.*,
        hk.hub_customer_key,
        {{ dbt_utils.generate_surrogate_key([
            'sd.company_name',
            'sd.contact_name',
            'sd.contact_title',
            'sd.address',
            'sd.city',
            'sd.region',
            'sd.postal_code',
            'sd.country',
            'sd.phone',
            'sd.fax'
        ]) }} AS hashdiff
    FROM source_data AS sd
    INNER JOIN hub_keys AS hk ON sd.customer_id = hk.customer_id
)

-- Final selection of attributes for the satellite table.
SELECT
    {{ dbt_utils.generate_surrogate_key(['hub_customer_key', 'hashdiff']) }} AS sat_customer_key,
    hub_customer_key,
    company_name,
    contact_name,
    contact_title,
    address,
    city,
    region,
    postal_code,
    country,
    phone,
    fax,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
    WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
