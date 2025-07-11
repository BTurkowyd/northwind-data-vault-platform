-- This model creates a hub for categories in the Northwind database.
{{ config(
    unique_key='hub_category_key',
    merge_update_columns=['category_id', 'load_ts', 'record_source']
) }}

-- Create a hub for categories with a surrogate key for category_id and load timestamp.
SELECT
    {{ dbt_utils.generate_surrogate_key(['category_id']) }} AS hub_category_key,
    category_id,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM {{ ref('stg_categories') }}

{% if is_incremental() %}
    WHERE category_id NOT IN (SELECT category_id FROM {{ this }})
{% endif %}
