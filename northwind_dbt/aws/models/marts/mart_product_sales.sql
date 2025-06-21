-- This mart aggregates total sales revenue, order count, and quantity per product in the Northwind database.

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

-- Calculate revenue per product line.
product_lines as (
    select
        l.hub_product_key,
        p.unit_price,
        p.quantity,
        p.discount,
        p.unit_price * p.quantity * (1 - p.discount) as revenue,
        p.load_ts
    from {{ ref('link_order_products') }} l
    join latest_sat_order_products p
        on l.link_order_product_key = p.link_order_product_key
),

-- Aggregate revenue, order count, and quantity per product.
aggregated as (
    select
        hub_product_key,
        CAST(ROUND(sum(revenue), 2) AS DECIMAL(10,2)) as total_revenue,
        count(*) as total_orders,
        sum(quantity) as total_quantity
    from product_lines
    group by hub_product_key
)

-- Final selection: one row per product with total revenue, order count, and quantity.
select * from aggregated;
