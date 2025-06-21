-- This mart aggregates sales revenue, freight, and order count by region, city, and month in the Northwind database.

-- Get the latest version of each order-product line from the satellite table.
with latest_sat_order_products as (
    select
        link_order_product_key,
        unit_price,
        quantity,
        discount,
        load_ts
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

-- Calculate revenue per order line.
order_lines as (

    select
        l.link_order_product_key,
        l.hub_order_key,
        l.hub_product_key,
        p.unit_price,
        p.quantity,
        p.discount,
        p.unit_price * p.quantity * (1 - p.discount) as revenue,
        p.load_ts as line_load_ts
    from {{ ref('link_order_products') }} l
    join latest_sat_order_products p
        on l.link_order_product_key = p.link_order_product_key

),

-- Get order-level region, city, and shipment details.
orders as (
    select
        hub_order_key,
        order_date,
        ship_city,
        ship_region,
        ship_country,
        freight
    from {{ ref('sat_orders') }}
),

-- Join order lines with order details.
region_sales as (
    select
        ol.link_order_product_key,
        ol.hub_order_key,
        ol.hub_product_key,
        o.order_date,
        o.ship_city,
        o.ship_region,
        o.ship_country,
        ol.revenue,
        o.freight,
        ol.line_load_ts
    from order_lines ol
    left join orders o
        on ol.hub_order_key = o.hub_order_key
)

select
    ship_country,
    ship_region,
    ship_city,
    date_trunc('month', order_date) as month,
    CAST(ROUND(sum(revenue), 2) AS DECIMAL(10,2)) as total_revenue,
    CAST(ROUND(sum(freight), 2) AS DECIMAL(10,2)) as total_freight,
    count(distinct hub_order_key) as order_count
from region_sales
group by 1, 2, 3, 4
