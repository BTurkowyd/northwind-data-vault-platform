from pyspark.sql import SparkSession, DataFrame


def write_to_iceberg(spark: SparkSession, df: DataFrame, table_name: str, db: str):
    df.createOrReplaceTempView(f"tmp_{table_name}")
    spark.sql(
        f"""
        CREATE TABLE IF NOT EXISTS glue_catalog.{db}.{table_name}
        USING iceberg
        TBLPROPERTIES ('format-version' = '2')
        AS SELECT * FROM tmp_{table_name}
    """
    )
