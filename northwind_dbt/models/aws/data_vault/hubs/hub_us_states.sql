{{ config(
    unique_key='hub_state_key',
    merge_update_columns=['state_id', 'load_ts', 'record_source']
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['state_id']) }} AS hub_state_key,
    state_id,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM {{ ref('stg_us_states') }}

{% if is_incremental() %}
    WHERE state_id NOT IN (SELECT state_id FROM {{ this }})
{% endif %}
