{% macro snowflake_create_external_table(schema, table_name, stage_subpath) %}
  {% set full_table_name = schema ~ '.' ~ table_name %}
  {% set location = '@S3_STAGE_DEV/' ~ stage_subpath %}

  {% set query %}
    CREATE OR REPLACE EXTERNAL TABLE {{ full_table_name }}
    LOCATION = {{ location }}
    AUTO_REFRESH = FALSE
    FILE_FORMAT = (TYPE = PARQUET);
  {% endset %}

  {{ log("Creating external table: " ~ full_table_name ~ " from stage path: " ~ location, info=True) }}
  {{ run_query(query.strip()) }}
{% endmacro %}
