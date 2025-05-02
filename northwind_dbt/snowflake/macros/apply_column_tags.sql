{% macro apply_column_tags() %}
  {% if target.type != 'snowflake' %}
    {{ log("Skipping column tagging — not running on Snowflake target", info=True) }}
    {% do return(none) %}
  {% endif %}

  {{ log("Starting apply_column_tags() macro", info=True) }}

  {% set full_table = model.database ~ '.' ~ model.schema ~ '.' ~ model.alias %}
  {{ log("Full table name: " ~ full_table, info=True) }}

  {% for col in model.columns.values() %}
    {% set col_name = col.name %}
    {% set meta = col.meta %}
    {{ log("Processing column: " ~ col_name, info=True) }}

    {% if meta.get('pii') == true %}
      {% set stmt = 'ALTER TABLE ' ~ full_table ~ ' MODIFY COLUMN ' ~ col_name ~ ' SET TAG "pii" = \'true\'' %}
      {{ log("Executing: " ~ stmt, info=True) }}
      {% do run_query(stmt) %}
    {% endif %}

    {% if meta.get('sensitivity') %}
      {% set val = meta['sensitivity'] %}
      {% set stmt = 'ALTER TABLE ' ~ full_table ~ ' MODIFY COLUMN ' ~ col_name ~ ' SET TAG "sensitivity" = \'' ~ val ~ '\'' %}
      {{ log("Executing: " ~ stmt, info=True) }}
      {% do run_query(stmt) %}
    {% endif %}
  {% endfor %}
{% endmacro %}
