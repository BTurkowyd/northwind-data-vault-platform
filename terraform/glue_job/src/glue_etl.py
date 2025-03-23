import json
import sys
import boto3
from awsglue.utils import getResolvedOptions
from pyspark.sql import SparkSession

print("Starting Glue ETL job...")

# Get the Aurora credentials from Secrets Manager
args = getResolvedOptions(sys.argv, ['AURORA_CREDS_SECRET', 'DESTINATION_BUCKET'])
client = boto3.client('secretsmanager', region_name='eu-central-1')

try:
    secret = client.get_secret_value(SecretId=args['AURORA_CREDS_SECRET'])
    secrets = json.loads(secret['SecretString'])
    print("Successfully retrieved Aurora credentials.")
    print(secrets)

except Exception as e:
    print(f"ERROR: Failed to retrieve credentials from Secrets Manager: {e}")
    sys.exit(1)

spark = SparkSession.builder \
    .config("spark.sql.catalog.glue_catalog", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.glue_catalog.warehouse", f"s3://{args['DESTINATION_BUCKET']}/iceberg") \
    .config("spark.sql.catalog.glue_catalog.catalog-impl", "org.apache.iceberg.aws.glue.GlueCatalog") \
    .config("spark.sql.catalog.glue_catalog.io-impl", "org.apache.iceberg.aws.s3.S3FileIO") \
    .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
    .getOrCreate()

print("Current catalog:", spark.conf.get("spark.sql.defaultCatalog"))

# Construct JDBC URL
jdbc_url = f"jdbc:postgresql://{secrets['host']}:{secrets['port']}/{secrets['dbname']}"

# Load data from Aurora PostgreSQL
try:
    df = spark.read \
        .format("jdbc") \
        .option("url", jdbc_url) \
        .option("dbtable", "orders") \
        .option("user", secrets['username']) \
        .option("password", secrets['password']) \
        .option("driver", "org.postgresql.Driver") \
        .load()

    print("Successfully loaded data from Aurora.")
    df.printSchema()  # Verify the schema

except Exception as e:
    print(f"ERROR: Failed to load data from Aurora: {e}")
    sys.exit(1)

# Register the DataFrame as a temporary SQL view
df.createOrReplaceTempView("tmp_orders")

# Use Spark SQL to write to Iceberg table in Glue Catalog
try:
    spark.sql("""
    CREATE TABLE IF NOT EXISTS glue_catalog.ecommerce_db_dev.orders
    USING iceberg
    TBLPROPERTIES ('format-version' = '2')
    AS SELECT * FROM tmp_orders
    """)
    print("Successfully wrote data to Iceberg table in Glue Catalog.")

except Exception as e:
    print(f"ERROR: Failed to write Iceberg table to S3: {e}")
    sys.exit(1)

spark.stop()