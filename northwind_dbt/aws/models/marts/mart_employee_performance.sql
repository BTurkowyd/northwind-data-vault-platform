-- This mart aggregates sales revenue and line counts per employee in the Northwind database.

-- Map orders to employees via the link table.
with order_employee as (
    select
        hub_employee_key,
        hub_order_key
    from {{ ref('link_order_customer_employee') }}
),

-- Calculate revenue per order line for each employee.
sales as (
    select
        oe.hub_employee_key,
        p.unit_price * p.quantity * (1 - p.discount) as revenue
    from order_employee oe
    join {{ ref('link_order_products') }} l on oe.hub_order_key = l.hub_order_key
    join {{ ref('sat_order_products') }} p on l.link_order_product_key = p.link_order_product_key
),

-- Aggregate total revenue and line count per employee.
aggregated as (
    select
        hub_employee_key,
        CAST(ROUND(sum(revenue), 2) AS DECIMAL(10,2)) as total_revenue,
        count(*) as total_lines
    from sales
    group by hub_employee_key
)

-- Final selection: one row per employee with total revenue and line count.
select * from aggregated;
