-- This satellite table captures the attributes of orders in the Northwind database.
{{ config(
    unique_key='sat_order_key',
    merge_update_columns=['hashdiff', 'load_ts', 'order_date', 'required_date', 'shipped_date', 'ship_via', 'freight', 'ship_name', 'ship_address', 'ship_city', 'ship_region', 'ship_postal_code', 'ship_country', 'record_source']
) }}

-- The satellite table is built from the staging model 'stg_orders'.
WITH source_data AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

-- The hub table for orders is referenced to get the hub keys.
hub_orders AS (
    SELECT
        order_id,
        hub_order_key
    FROM {{ ref('hub_orders') }}
),

-- The satellite table is constructed by joining the source data with the hub keys.
prepared AS (
    SELECT
        sd.*,
        ho.hub_order_key,
        {{ dbt_utils.generate_surrogate_key([
            'sd.order_date',
            'sd.required_date',
            'sd.shipped_date',
            'sd.ship_via',
            'sd.freight',
            'sd.ship_name',
            'sd.ship_address',
            'sd.ship_city',
            'sd.ship_region',
            'sd.ship_postal_code',
            'sd.ship_country'
        ]) }} AS hashdiff
    FROM source_data AS sd
    INNER JOIN hub_orders AS ho ON sd.order_id = ho.order_id
)

-- Final selection of attributes for the satellite table.
SELECT
    {{ dbt_utils.generate_surrogate_key(['hub_order_key', 'hashdiff']) }} AS sat_order_key,
    hub_order_key,
    order_date,
    required_date,
    shipped_date,
    ship_via,
    freight,
    ship_name,
    ship_address,
    ship_city,
    ship_region,
    ship_postal_code,
    ship_country,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
    WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
