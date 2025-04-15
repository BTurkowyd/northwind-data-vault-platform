{{ config(
    materialized='incremental',
    unique_key='link_order_product_key',
    on_schema_change='sync_all_columns'
) }}

with order_customer as (
    select
        link_order_cust_emp_key,
        hub_order_key,
        hub_customer_key
    from {{ ref('link_order_customer_employee') }}
),

customer_details as (
    select
        hub_customer_key,
        company_name,
        country
    from {{ ref('sat_customers') }}
),

sales as (
    select
        p.link_order_product_key,
        oc.hub_customer_key,
        cd.company_name,
        cd.country,
        p.unit_price * p.quantity * (1 - p.discount) as revenue,
        p.load_ts
    from {{ ref('link_order_products') }} l
    join {{ ref('sat_order_products') }} p on l.link_order_product_key = p.link_order_product_key
    join order_customer oc on l.hub_order_key = oc.hub_order_key
    join customer_details cd on oc.hub_customer_key = cd.hub_customer_key
)

select * from sales;
