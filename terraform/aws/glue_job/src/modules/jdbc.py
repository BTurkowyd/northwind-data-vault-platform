from pyspark.sql import SparkSession, DataFrame


def get_jdbc_options(jdbc_url: str, secrets: dict) -> dict:
    return {
        "url": jdbc_url,
        "user": secrets["username"],
        "password": secrets["password"],
        "driver": "org.postgresql.Driver",
    }


def fetch_table_names(spark: SparkSession, jdbc_options: dict) -> list[str]:
    query = """
        (SELECT table_name
         FROM information_schema.tables
         WHERE table_schema = 'public' AND table_type = 'BASE TABLE') AS user_tables
    """
    df = (
        spark.read.format("jdbc")
        .options(**jdbc_options, dbtable=query)
        .load()
        .select("table_name")
    )
    return [row["table_name"] for row in df.collect()]


def load_table_as_df(
    spark: SparkSession, table_name: str, jdbc_options: dict
) -> DataFrame:
    return spark.read.format("jdbc").options(**jdbc_options, dbtable=table_name).load()
