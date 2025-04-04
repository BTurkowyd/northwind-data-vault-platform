SELECT
    *,
    '{{ var("record_source") }}.suppliers' AS record_source
FROM northwind_iceberg_dev.suppliers
