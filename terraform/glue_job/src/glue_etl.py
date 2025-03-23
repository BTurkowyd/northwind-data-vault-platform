import json
import sys
import boto3
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
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

# Create a GlueContext
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init("ecommerce-db-to-s3", args)

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

# Convert to Iceberg format and save to S3
try:
    df.write \
        .format("iceberg") \
        .option("write-format", "parquet") \
        .option("write.distribution-mode", "hash") \
        .mode("overwrite") \
        .save(f"s3://{args['DESTINATION_BUCKET']}/iceberg/orders")

    print("Successfully wrote data to Iceberg table in S3.")

except Exception as e:
    print(f"ERROR: Failed to write Iceberg table to S3: {e}")
    sys.exit(1)

# Commit Glue job
job.commit()