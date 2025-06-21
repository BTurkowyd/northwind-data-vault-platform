-- This macro applies column-level tags (such as 'pii' and 'sensitivity') to all models in the current dbt project for Snowflake.
-- It iterates over all models, checks column metadata, and issues ALTER TABLE statements to set tags accordingly.

{% macro apply_column_tags_for_all_models() %}
  -- Only run on Snowflake targets.
  {% if target.type != 'snowflake' %}
    {{ log("Not running on Snowflake — skipping tagging", info=True) }}
    {% do return(none) %}
  {% endif %}

  {{ log("Applying column tags for all models...", info=True) }}

  -- Iterate over all nodes in the dbt graph.
  {% for node in graph.nodes.values() %}
    -- Only process models in the current project.
    {% if node.resource_type == 'model' and node.package_name == project_name %}
      {% set full_table = node.database ~ '.' ~ node.schema ~ '.' ~ node.alias %}
      {% set columns = node.columns.values() %}

      -- Iterate over all columns in the model.
      {% for col in columns %}
        {% set col_name = col.name %}
        {% set meta = col.meta %}

        -- If the column is marked as PII, set the 'pii' tag to 'true'.
        {% if meta.get('pii') == true %}
          {% set stmt = "ALTER TABLE " ~ full_table ~ " MODIFY COLUMN " ~ col_name ~ " SET TAG \"pii\" = 'true'" %}
          {{ log("Executing: " ~ stmt, info=True) }}
          {% do run_query(stmt) %}
        {% endif %}

        -- If the column has a 'sensitivity' meta value, set the 'sensitivity' tag accordingly.
        {% if meta.get('sensitivity') %}
          {% set stmt = "ALTER TABLE " ~ full_table ~ " MODIFY COLUMN " ~ col_name ~ " SET TAG \"sensitivity\" = '" ~ meta.get('sensitivity') ~ "'" %}
          {{ log("Executing: " ~ stmt, info=True) }}
          {% do run_query(stmt) %}
        {% endif %}
      {% endfor %}
    {% endif %}
  {% endfor %}
{% endmacro %}
