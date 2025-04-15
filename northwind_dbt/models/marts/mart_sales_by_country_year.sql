{{ config(
    materialized='incremental',
    unique_key='link_order_product_key',
    on_schema_change='sync_all_columns'
) }}

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

orders as (
    select
        hub_order_key,
        order_date,
        ship_country,
        freight
    from {{ ref('sat_orders') }}
),

country_year_sales as (
    select
        ol.link_order_product_key,
        ol.hub_order_key,
        ol.hub_product_key,
        o.order_date,
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
    date_trunc('year', order_date) as year,
    CAST(ROUND(sum(revenue), 2) AS DECIMAL(10,2)) as total_revenue,
    CAST(ROUND(sum(freight), 2) AS DECIMAL(10,2)) as total_freight,
    count(distinct hub_order_key) as order_count
from country_year_sales
group by 1, 2
