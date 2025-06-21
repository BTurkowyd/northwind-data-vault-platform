-- This link table connects products, suppliers, and categories in the Northwind database.
{{ config(
    unique_key='link_product_supp_cat_key'
) }}

-- The link table is built from the staging model 'stg_products',
WITH source_data AS (
    SELECT * FROM {{ ref('stg_products') }}
),

-- The hub table for products is referenced to get their keys.
hub_products AS (
    SELECT
        product_id,
        hub_product_key
    FROM {{ ref('hub_products') }}
),

-- The hub table for suppliers is referenced to get their keys.
hub_suppliers AS (
    SELECT
        supplier_id,
        hub_supplier_key
    FROM {{ ref('hub_suppliers') }}
),

-- The hub table for categories is referenced to get their keys.
hub_categories AS (
    SELECT
        category_id,
        hub_category_key
    FROM {{ ref('hub_categories') }}
)

-- The link table is constructed by joining the source data with the hub tables.
-- It generates a surrogate key for the link and includes load timestamp and record source.
-- Joins are made on product_id, supplier_id, and category_id to get the corresponding keys.
SELECT
    {{ dbt_utils.generate_surrogate_key(['hp.hub_product_key', 'hs.hub_supplier_key', 'hc.hub_category_key']) }} AS link_product_supp_cat_key,
    hp.hub_product_key,
    hs.hub_supplier_key,
    hc.hub_category_key,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    sd.record_source
FROM source_data AS sd
INNER JOIN hub_products AS hp ON sd.product_id = hp.product_id
INNER JOIN hub_suppliers AS hs ON sd.supplier_id = hs.supplier_id
INNER JOIN hub_categories AS hc ON sd.category_id = hc.category_id

{% if is_incremental() %}
    WHERE
        {{ dbt_utils.generate_surrogate_key(['hp.hub_product_key', 'hs.hub_supplier_key', 'hc.hub_category_key']) }}
        NOT IN (SELECT link_product_supp_cat_key FROM {{ this }})
{% endif %}
