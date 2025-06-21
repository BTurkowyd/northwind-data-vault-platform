-- This model creates a hub for territories in the Northwind database.
{{ config(
    unique_key='hub_territory_key',
    merge_update_columns=['territory_id', 'load_ts', 'record_source']
) }}

-- Create a hub table for territories with a surrogate key for territory_id and load timestamp.
SELECT
    {{ dbt_utils.generate_surrogate_key(['territory_id']) }} AS hub_territory_key,
    territory_id,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM {{ ref('stg_territories') }}

{% if is_incremental() %}
    WHERE territory_id NOT IN (SELECT territory_id FROM {{ this }})
{% endif %}
