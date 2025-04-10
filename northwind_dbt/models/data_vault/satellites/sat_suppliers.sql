{{ config(
    unique_key='sat_supplier_key',
    merge_update_columns=['hashdiff', 'load_ts', 'company_name', 'contact_name', 'contact_title', 'address', 'city', 'region', 'postal_code', 'country', 'phone', 'fax', 'homepage', 'record_source']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_suppliers') }}
),

hub_keys AS (
    SELECT
        supplier_id,
        hub_supplier_key
    FROM {{ ref('hub_suppliers') }}
),

prepared AS (
    SELECT
        sd.*,
        hk.hub_supplier_key,
        {{ dbt_utils.generate_surrogate_key([
            'sd.company_name', 'sd.contact_name', 'sd.contact_title', 'sd.address',
            'sd.city', 'sd.region', 'sd.postal_code', 'sd.country',
            'sd.phone', 'sd.fax', 'sd.homepage'
        ]) }} AS hashdiff
    FROM source_data AS sd
    INNER JOIN hub_keys AS hk ON sd.supplier_id = hk.supplier_id
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['hub_supplier_key', 'hashdiff']) }} AS sat_supplier_key,
    hub_supplier_key,
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
    homepage,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
