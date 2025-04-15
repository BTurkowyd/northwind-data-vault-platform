{{ config(
    unique_key='link_order_product_key',
    on_schema_change='sync_all_columns'
) }}

with order_lines as (

    select
        l.link_order_product_key,
        l.hub_order_key,
        l.hub_product_key,
        p.unit_price,
        p.quantity,
        p.discount,
        -- Revenue calc
        p.unit_price * p.quantity * (1 - p.discount) as revenue,
        p.load_ts as line_load_ts,
        p.record_source as line_record_source
    from {{ ref('link_order_products') }} l
    join {{ ref('sat_order_products') }} p
        on l.link_order_product_key = p.link_order_product_key

),

orders as (
    select
        o.hub_order_key,
        o.order_date,
        o.required_date,
        o.shipped_date,
        o.ship_via,
        o.freight,
        o.ship_name,
        o.ship_city,
        o.ship_country
    from {{ ref('sat_orders') }} o
),

final as (

    select
        ol.link_order_product_key,
        ol.hub_order_key,
        ol.hub_product_key,
        o.order_date,
        o.shipped_date,
        o.freight,
        ol.unit_price,
        ol.quantity,
        ol.discount,
        ol.revenue,
        ol.line_load_ts,
        ol.line_record_source
    from order_lines ol
    left join orders o
        on ol.hub_order_key = o.hub_order_key

)

select * from final
