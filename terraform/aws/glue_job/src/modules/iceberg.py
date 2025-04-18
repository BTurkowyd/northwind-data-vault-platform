import re

from pyspark.sql import SparkSession, DataFrame


def write_to_iceberg(spark: SparkSession, df: DataFrame, table_name: str, db: str):
    """
    Write a DataFrame to an Iceberg table in Glue Catalog.

    Args:
        spark: SparkSession
        df: Spark DataFrame
        table_name: target table name (must be alphanumeric + underscore, start with letter/underscore)
        db: Glue Catalog database name (same naming rules)
    """
    identifier_pattern = r"^[A-Za-z_][A-Za-z0-9_]*$"

    if not table_name or not re.match(identifier_pattern, table_name):
        raise ValueError(f"Invalid table name: '{table_name}'")
    if not db or not re.match(identifier_pattern, db):
        raise ValueError(f"Invalid database name: '{db}'")

    df.createOrReplaceTempView(f"tmp_{table_name}")
    spark.sql(
        f"""
        CREATE TABLE IF NOT EXISTS glue_catalog.{db}.{table_name}
        USING iceberg
        TBLPROPERTIES ('format-version' = '2')
        AS SELECT * FROM tmp_{table_name}
        """
    )
