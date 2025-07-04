-- This satellite table captures the attributes of products in the Northwind database.
{{ config(
    unique_key='sat_product_key',
    merge_update_columns=['hashdiff', 'load_ts', 'product_name', 'quantity_per_unit', 'unit_price', 'units_in_stock', 'units_on_order', 'reorder_level', 'discontinued', 'record_source']
) }}

-- The satellite table is built from the staging model 'stg_products'.
WITH source_data AS (
    SELECT * FROM {{ ref('stg_products') }}
),

-- The hub table for products is referenced to get the hub keys.
hub_products AS (
    SELECT
        product_id,
        hub_product_key
    FROM {{ ref('hub_products') }}
),

-- The satellite table is constructed by joining the source data with the hub keys.
prepared AS (
    SELECT
        sd.*,
        hp.hub_product_key,
        {{ dbt_utils.generate_surrogate_key([
            'sd.product_name',
            'sd.quantity_per_unit',
            'sd.unit_price',
            'sd.units_in_stock',
            'sd.units_on_order',
            'sd.reorder_level',
            'sd.discontinued'
        ]) }} AS hashdiff
    FROM source_data AS sd
    INNER JOIN hub_products AS hp ON sd.product_id = hp.product_id
)

-- Final selection of attributes for the satellite table.
SELECT
    {{ dbt_utils.generate_surrogate_key(['hub_product_key', 'hashdiff']) }} AS sat_product_key,
    hub_product_key,
    product_name,
    quantity_per_unit,
    unit_price,
    units_in_stock,
    units_on_order,
    reorder_level,
    discontinued,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
    WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
