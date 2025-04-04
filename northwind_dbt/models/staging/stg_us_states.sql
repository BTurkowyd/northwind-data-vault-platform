SELECT
    *,
    '{{ var("record_source") }}.us_states' AS record_source
FROM northwind_iceberg_dev.us_states
