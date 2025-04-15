{{ config(
    materialized='incremental',
    unique_key='hub_product_key',
    on_schema_change='sync_all_columns',
) }}

with product_lines as (
    select
        l.hub_product_key,
        p.unit_price,
        p.quantity,
        p.discount,
        p.unit_price * p.quantity * (1 - p.discount) as revenue,
        p.load_ts
    from {{ ref('link_order_products') }} l
    join {{ ref('sat_order_products') }} p on l.link_order_product_key = p.link_order_product_key
),

aggregated as (
    select
        hub_product_key,
        sum(unit_price * quantity * (1 - discount)) as total_revenue,
        count(*) as total_orders,
        sum(quantity) as total_quantity
    from product_lines
    group by hub_product_key
)

select * from aggregated;
