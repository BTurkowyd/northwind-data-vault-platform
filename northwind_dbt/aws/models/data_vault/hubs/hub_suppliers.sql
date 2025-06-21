-- This model creates a hub for suppliers in the Northwind database.
{{ config(
    unique_key='hub_supplier_key',
    merge_update_columns=['supplier_id', 'load_ts', 'record_source']
) }}

-- Create a hub table for suppliers with a surrogate key for supplier_id and load timestamp.
SELECT
    {{ dbt_utils.generate_surrogate_key(['supplier_id']) }} AS hub_supplier_key,
    supplier_id,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM {{ ref('stg_suppliers') }}

{% if is_incremental() %}
    WHERE supplier_id NOT IN (SELECT supplier_id FROM {{ this }})
{% endif %}
