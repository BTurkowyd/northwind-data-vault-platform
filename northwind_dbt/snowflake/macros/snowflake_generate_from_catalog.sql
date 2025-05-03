{% macro snowflake_generate_from_catalog() %}
  {% set raw_json = env_var("DBT_JSON_CATALOG") %}
  {% set catalog = fromjson(raw_json) %}
  {% set nodes = catalog['nodes'] %}

  {% for node_key, node in nodes.items() %}
    {% set metadata = node['metadata'] %}
    {% set table_name = metadata['name'] %}

    {% if metadata['type'] == 'iceberg_table' and table_name.startswith('mart_') %}
      {% set schema = 'NORTHWIND_SCHEMA_DEV' %}
      {% set database = 'NORTHWIND_DB_DEV' %}
      {% set full_table_name = database ~ '.' ~ schema ~ '.' ~ table_name %}
      {% set external_table_name = full_table_name ~ '_external' %}
      {% set materialized_table_name = full_table_name %}
      {% set stage_path = table_name %}
      {% set location = '@S3_STAGE_DEV/' ~ stage_path %}

      {# Column definitions #}
      {% set column_definitions = [] %}
      {% for col_name, col in node['columns'].items() %}
        {% set col_type = col['type'] | upper %}
        {% if col_name == 'load_ts' %}
          {% do column_definitions.append(col_name ~ ' TIMESTAMP AS (TO_TIMESTAMP((VALUE:"' ~ col_name ~ '"::NUMBER) / 1000000))') %}
        {% else %}
          {% do column_definitions.append(col_name ~ ' ' ~ col_type ~ ' AS (VALUE:"' ~ col_name ~ '"::' ~ col_type ~ ')') %}
        {% endif %}
      {% endfor %}

      {{ log("Creating external table: " ~ external_table_name ~ " with columns:\n" ~ column_definitions | join(',\n'), info=True) }}

      {% set create_external_table %}
        CREATE OR REPLACE EXTERNAL TABLE {{ external_table_name }} (
          {{ column_definitions | join(',\n  ') }}
        )
        LOCATION = {{ location }}
        AUTO_REFRESH = FALSE
        FILE_FORMAT = (TYPE = PARQUET);
      {% endset %}

      {{ run_query(create_external_table.strip()) }}
      {{ run_query('ALTER EXTERNAL TABLE ' ~ external_table_name ~ ' REFRESH') }}

    {% else %}
      {{ log("Skipping table: " ~ table_name, info=True) }}
    {% endif %}
  {% endfor %}
{% endmacro %}
