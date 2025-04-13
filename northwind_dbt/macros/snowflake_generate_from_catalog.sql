{% macro snowflake_generate_from_catalog() %}
  {% set raw_json = env_var("DBT_JSON_CATALOG") %}
  {% set catalog = fromjson(raw_json) %}
  {% set nodes = catalog['nodes'] %}

  {% for node_key, node in nodes.items() %}
    {% set metadata = node['metadata'] %}
    {% if metadata['type'] == 'iceberg_table' %}
      {% set table_name = metadata['name'] %}
      {% set full_table_name = 'NORTHWIND_DB_DEV.NORTHWIND_SCHEMA_DEV.' ~ table_name %}
      {% set stage_path = table_name %}
      {% set location = '@S3_STAGE_DEV/' ~ stage_path %}

      {{ log("Creating external table: " ~ full_table_name ~ " from stage path: @S3_STAGE_DEV/" ~ stage_path, info=True) }}

      {% set query %}
        CREATE OR REPLACE EXTERNAL TABLE {{ full_table_name }}
        LOCATION = {{ location }}
        AUTO_REFRESH = FALSE
        FILE_FORMAT = (TYPE = PARQUET);
      {% endset %}

      {{ run_query(query.strip()) }}
    {% endif %}
  {% endfor %}
{% endmacro %}
