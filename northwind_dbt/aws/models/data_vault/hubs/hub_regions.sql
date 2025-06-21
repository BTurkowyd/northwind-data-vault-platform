-- This model creates a hub table for regions in the Northwind database.
{{ config(
    unique_key='hub_region_key',
    merge_update_columns=['region_id', 'load_ts', 'record_source']
) }}

-- Create a hub table for regions with a surrogate key for region_id and load timestamp.
SELECT
    {{ dbt_utils.generate_surrogate_key(['region_id']) }} AS hub_region_key,
    region_id,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM {{ ref('stg_region') }}

{% if is_incremental() %}
    WHERE region_id NOT IN (SELECT region_id FROM {{ this }})
{% endif %}
