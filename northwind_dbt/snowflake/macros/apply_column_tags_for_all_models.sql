{% macro apply_column_tags_for_all_models() %}
  {% if target.type != 'snowflake' %}
    {{ log("Not running on Snowflake — skipping tagging", info=True) }}
    {% do return(none) %}
  {% endif %}

  {{ log("Applying column tags for all models...", info=True) }}

  {% for node in graph.nodes.values() %}
    {% if node.resource_type == 'model' and node.package_name == project_name %}
      {% set full_table = node.database ~ '.' ~ node.schema ~ '.' ~ node.alias %}
      {% set columns = node.columns.values() %}

      {% for col in columns %}
        {% set col_name = col.name %}
        {% set meta = col.meta %}

        {% if meta.get('pii') == true %}
          {% set stmt = "ALTER TABLE " ~ full_table ~ " MODIFY COLUMN " ~ col_name ~ " SET TAG \"pii\" = 'true'" %}
          {{ log("Executing: " ~ stmt, info=True) }}
          {% do run_query(stmt) %}
        {% endif %}

        {% if meta.get('sensitivity') %}
          {% set stmt = "ALTER TABLE " ~ full_table ~ " MODIFY COLUMN " ~ col_name ~ " SET TAG \"sensitivity\" = '" ~ meta.get('sensitivity') ~ "'" %}
          {{ log("Executing: " ~ stmt, info=True) }}
          {% do run_query(stmt) %}
        {% endif %}
      {% endfor %}
    {% endif %}
  {% endfor %}
{% endmacro %}
