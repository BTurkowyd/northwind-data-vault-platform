-- This mart aggregates sales revenue per customer, including company and country, in the Northwind database.

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

-- Map orders to customers via the link table.
order_customer as (
    select
        link_order_cust_emp_key,
        hub_order_key,
        hub_customer_key
    from {{ ref('link_order_customer_employee') }}
),

-- Get customer details from the satellite table.
customer_details as (
    select
        hub_customer_key,
        company_name,
        country
    from {{ ref('sat_customers') }}
),

-- Calculate revenue per order line and join with customer details.
sales as (
    select
        l.link_order_product_key,
        oc.hub_customer_key,
        cd.company_name,
        cd.country,
        cast(round(p.unit_price * p.quantity * (1 - p.discount), 2) as decimal(10,2)) as revenue,
        p.load_ts
    from {{ ref('link_order_products') }} l
    join latest_sat_order_products p
        on l.link_order_product_key = p.link_order_product_key
    join order_customer oc
        on l.hub_order_key = oc.hub_order_key
    join customer_details cd
        on oc.hub_customer_key = cd.hub_customer_key
)

-- Final selection: one row per order-product line with customer and revenue info.
select * from sales;
