{{ config(
    unique_key='sat_customer_key',
    merge_update_columns=['hashdiff', 'load_ts', 'company_name', 'contact_name', 'contact_title', 'address', 'city', 'region', 'postal_code', 'country', 'phone', 'fax']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

hub_keys AS (
    SELECT
        customer_id,
        hub_customer_key
    FROM {{ ref('hub_customers') }}
),

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
    CAST(CURRENT_TIMESTAMP AS timestamp) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
