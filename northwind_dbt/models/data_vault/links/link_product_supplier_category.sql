{{ config(
    unique_key='link_product_supp_cat_key'
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_products') }}
),
hub_products AS (
    SELECT product_id, hub_product_key FROM {{ ref('hub_products') }}
),
hub_suppliers AS (
    SELECT supplier_id, hub_supplier_key FROM {{ ref('hub_suppliers') }}
),
hub_categories AS (
    SELECT category_id, hub_category_key FROM {{ ref('hub_categories') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['hp.hub_product_key', 'hs.hub_supplier_key', 'hc.hub_category_key']) }} AS link_product_supp_cat_key,
    hp.hub_product_key,
    hs.hub_supplier_key,
    hc.hub_category_key,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts,
    sd.record_source
FROM source_data sd
JOIN hub_products hp ON sd.product_id = hp.product_id
JOIN hub_suppliers hs ON sd.supplier_id = hs.supplier_id
JOIN hub_categories hc ON sd.category_id = hc.category_id

{% if is_incremental() %}
WHERE {{ dbt_utils.generate_surrogate_key(['hp.hub_product_key', 'hs.hub_supplier_key', 'hc.hub_category_key']) }}
    NOT IN (SELECT link_product_supp_cat_key FROM {{ this }})
{% endif %}