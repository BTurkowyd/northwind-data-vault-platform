{% macro snowflake_create_all_external_tables() %}
{% set tables = [
    "hub_categories",
    "hub_customer_customer_demo",
    "hub_customer_types",
    "hub_customers",
    "hub_employees",
    "hub_orders",
    "hub_products",
    "hub_regions",
    "hub_shippers",
    "hub_suppliers",
    "hub_territories",
    "hub_us_states",
    "link_customer_type",
    "link_employee_territories",
    "link_order_customer_employee",
    "link_order_products",
    "link_product_supplier_category",
    "sat_categories",
    "sat_customer_customer_demo",
    "sat_customer_types",
    "sat_customers",
    "sat_employees",
    "sat_order_products",
    "sat_orders",
    "sat_products",
    "sat_regions",
    "sat_shippers",
    "sat_suppliers",
    "sat_territories",
    "sat_us_states"
  ] %}

  {% for table in tables %}
    {% do snowflake_create_external_table('northwind_schema_dev', table, table) %}
  {% endfor %}
{% endmacro %}
