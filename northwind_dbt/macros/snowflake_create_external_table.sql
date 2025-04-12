{% macro create_external_table(name, path) %}
  CREATE OR REPLACE EXTERNAL TABLE northwind_data_vault.{{ name }}
    WITH LOCATION = @northwind_stage/{{ path }}
    FILE_FORMAT = (TYPE = PARQUET);
{% endmacro %}
