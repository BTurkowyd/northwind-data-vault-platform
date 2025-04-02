SELECT
    *,
    '{{ var("record_source") }}.us_states' as record_source
FROM northwind_iceberg_dev.us_states