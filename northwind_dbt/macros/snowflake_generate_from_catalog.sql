{% macro snowflake_generate_from_catalog() %}
  {% set raw_json = env_var("DBT_JSON_CATALOG") %}
  {% set catalog = fromjson(raw_json) %}
  {% set nodes = catalog['nodes'] %}

  {% for node_key, node in nodes.items() %}
    {% set metadata = node['metadata'] %}
    {% set table_name = metadata['name'] %}

    {% if metadata['type'] == 'iceberg_table' and table_name.startswith('mart_') %}
      {% set full_table_name = 'NORTHWIND_DB_DEV.NORTHWIND_SCHEMA_DEV.' ~ table_name %}
      {% set stage_path = table_name %}
      {% set location = '@S3_STAGE_DEV/' ~ stage_path %}

      {# Construct column definitions: name TYPE AS (VALUE:"col") #}
      {% set column_definitions = [] %}
      {% for col_name, col in node['columns'].items() %}
        {% set col_type = col['type'] | upper %}
        {% if col_name == 'load_ts' %}
          {% do column_definitions.append(col_name ~ ' TIMESTAMP AS (TO_TIMESTAMP((VALUE:"' ~ col_name ~ '"::NUMBER) / 1000000))') %}
        {% else %}
          {% do column_definitions.append(col_name ~ ' ' ~ col_type ~ ' AS (VALUE:"' ~ col_name ~ '"::' ~ col_type ~ ')') %}
        {% endif %}
      {% endfor %}

      {{ log("Creating external table: " ~ full_table_name ~ " with columns:\n" ~ column_definitions | join(',\n'), info=True) }}

      {% set query %}
        CREATE OR REPLACE EXTERNAL TABLE {{ full_table_name }} (
          {{ column_definitions | join(',\n  ') }}
        )
        LOCATION = {{ location }}
        AUTO_REFRESH = FALSE
        FILE_FORMAT = (TYPE = PARQUET);
      {% endset %}

      {{ run_query(query.strip()) }}
      {{ run_query('ALTER EXTERNAL TABLE ' ~ full_table_name ~ ' REFRESH') }}

    {% else %}
      {{ log("Skipping table: " ~ table_name, info=True) }}
    {% endif %}
  {% endfor %}
{% endmacro %}
