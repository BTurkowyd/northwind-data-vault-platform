{% macro apply_column_tags() %}
  {% if target.type != 'snowflake' %}
    {% do return([]) %}
  {% endif %}

  {% set statements = [] %}
  {% set full_table = model.database ~ '.' ~ model.schema ~ '.' ~ model.alias %}

  {% for col in model.columns.values() %}
    {% set col_name = col.name %}
    {% set meta = col.meta %}

    {% if meta.get('pii') == true %}
      {% set stmt = 'ALTER TABLE ' ~ full_table ~ ' MODIFY COLUMN ' ~ col_name ~ ' SET TAG "pii" = \'true\'' %}
      {{ log("Statement: " ~ stmt, info=True) }}
      {% do statements.append(stmt) %}
    {% endif %}

    {% if meta.get('sensitivity') %}
      {% set val = meta['sensitivity'] %}
      {% set stmt = 'ALTER TABLE ' ~ full_table ~ ' MODIFY COLUMN ' ~ col_name ~ ' SET TAG "sensitivity" = \'' ~ val ~ '\'' %}
        {{ log("Statement: " ~ stmt, info=True) }}
      {% do statements.append(stmt) %}
    {% endif %}
  {% endfor %}

  {% do return(statements) %}
{% endmacro %}
