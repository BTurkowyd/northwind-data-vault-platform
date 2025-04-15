{{ config(
    unique_key='link_order_product_key',
    on_schema_change='sync_all_columns'
) }}

with latest_sat_order_products as (
    select *
    from (
        select
            *,
            row_number() over (
                partition by link_order_product_key
                order by load_ts desc
            ) as row_num
        from {{ ref('sat_order_products') }}
    ) as ranked
    where row_num = 1
),

order_lines as (
    select
        l.link_order_product_key,
        l.hub_order_key,
        l.hub_product_key,
        p.unit_price,
        p.quantity,
        p.discount,
        -- Revenue calc
        round(p.unit_price * p.quantity * (1 - p.discount), 2) as revenue,
        p.load_ts as line_load_ts,
        p.record_source as line_record_source
    from {{ ref('link_order_products') }} l
    join latest_sat_order_products p
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
        cast(round(ol.revenue, 2) as decimal(10,2)) as revenue,
        ol.line_load_ts,
        ol.line_record_source
    from order_lines ol
    left join orders o
        on ol.hub_order_key = o.hub_order_key

)

select * from final
