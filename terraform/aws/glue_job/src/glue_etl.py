import sys
import logging
from modules.helpers import (
    create_spark_session,
    get_aurora_credentials,
    get_job_arguments,
    configure_logging,
)

args = get_job_arguments()

debug = args["DEBUG"]

configure_logging(debug, args)

logging.info("Starting Glue ETL job...")

try:
    secrets = get_aurora_credentials(args["AURORA_CREDS_SECRET"])
    logging.info("Successfully retrieved Aurora credentials.")
    if debug:
        logging.debug(f"Secrets: {secrets}")

except Exception as e:
    logging.error(f"ERROR: Failed to retrieve credentials from Secrets Manager: {e}")
    sys.exit(1)

spark = create_spark_session(args)

if debug:
    logging.debug("Spark session created.")
    logging.debug(f"Current catalog: {spark.conf.get('spark.sql.defaultCatalog')}")

# Construct JDBC URL
jdbc_url = f"jdbc:postgresql://{secrets['host']}:{secrets['port']}/{secrets['dbname']}"

# Fetch the names of the tables in the Aurora database from the public schema, store them in a list.
try:
    table_filter_query = """
            (SELECT table_name
             FROM information_schema.tables
             WHERE table_schema = 'public' AND table_type = 'BASE TABLE') AS user_tables
        """

    tables = (
        spark.read.format("jdbc")
        .option("url", jdbc_url)
        .option("user", secrets["username"])
        .option("password", secrets["password"])
        .option("driver", "org.postgresql.Driver")
        .option("dbtable", table_filter_query)
        .load()
        .select("table_name")
        .collect()
    )

    table_names = [table["table_name"] for table in tables]

    logging.info("Successfully fetched table names from Aurora.")
    logging.info(f"Tables in Aurora: {table_names}")
except Exception as e:
    logging.error(f"ERROR: Failed to fetch table names from Aurora: {e}")
    sys.exit(1)

# Load data from Aurora PostgreSQL from all tables
for table_name in table_names:
    try:
        df = (
            spark.read.format("jdbc")
            .option("url", jdbc_url)
            .option("dbtable", table_name)
            .option("user", secrets["username"])
            .option("password", secrets["password"])
            .option("driver", "org.postgresql.Driver")
            .load()
        )

        logging.info(f"Successfully loaded data from {table_name}.")
        df.printSchema()  # Verify the schema

    except Exception as e:
        logging.error(f"ERROR: Failed to load data from {table_name}: {e}")
        sys.exit(1)

    # Register the DataFrame as a temporary SQL view
    df.createOrReplaceTempView(f"tmp_{table_name}")

    # Use Spark SQL to write to Iceberg table in Glue Catalog
    try:
        spark.sql(
            f"""
        CREATE TABLE IF NOT EXISTS glue_catalog.{args['GLUE_DATABASE']}.{table_name}
        USING iceberg
        TBLPROPERTIES ('format-version' = '2')
        AS SELECT * FROM tmp_{table_name}
        """
        )
        logging.info(
            f"Successfully wrote data to Iceberg table in Glue Catalog for {table_name}."
        )

    except Exception as e:
        logging.error(
            f"ERROR: Failed to write Iceberg table to S3 for {table_name}: {e}"
        )
        sys.exit(1)

    del df  # Delete the DataFrame to free up memory

logging.info("Glue ETL job completed.")

# End of script
spark.stop()
