import sys
import logging
import traceback

# Import helper functions for Spark session, credentials, arguments, and logging
from modules.helpers import (
    create_spark_session,
    get_aurora_credentials,
    get_job_arguments,
    configure_logging,
)
from modules.jdbc import fetch_table_names, load_table_as_df, get_jdbc_options
from modules.iceberg import write_to_iceberg


def main():
    # Parse job arguments (from Glue job parameters/environment)
    args = get_job_arguments()
    debug = args["DEBUG"]

    # Configure logging based on debug flag and arguments
    configure_logging(debug, args)
    logging.info("Starting Glue ETL job...")

    try:
        # Retrieve Aurora credentials from AWS Secrets Manager
        secrets = get_aurora_credentials(args["AURORA_CREDS_SECRET"])
        logging.info("Successfully retrieved Aurora credentials.")
        if debug:
            logging.debug(f"Secrets: {secrets}")

    except Exception as e:
        logging.error(
            f"ERROR: Failed to retrieve credentials from Secrets Manager: {e}"
        )
        sys.exit(1)

    # Create a Spark session for Glue
    spark = create_spark_session(args)

    if debug:
        logging.debug("Spark session created.")
        logging.debug(f"Current catalog: {spark.conf.get('spark.sql.defaultCatalog')}")

    # Construct JDBC URL for Aurora PostgreSQL
    jdbc_url = (
        f"jdbc:postgresql://{secrets['host']}:{secrets['port']}/{secrets['dbname']}"
    )

    # Set JDBC options for connecting to Aurora
    jdbc_options = get_jdbc_options(jdbc_url, secrets)

    # Fetch the names of all tables in the Aurora database (public schema)
    try:
        table_names = fetch_table_names(spark, jdbc_options)

        logging.info("Successfully fetched table names from Aurora.")
        logging.info(f"Tables in Aurora: {table_names}")
    except Exception as e:
        logging.error(f"ERROR: Failed to fetch table names from Aurora: {e}")
        sys.exit(1)

    # Iterate over all tables and extract data from Aurora, then write to Iceberg
    for table_name in table_names:
        try:
            # Load table data as a Spark DataFrame
            df = load_table_as_df(spark, table_name, jdbc_options)
            logging.info(f"Successfully loaded data from {table_name}.")
            df.printSchema()  # Print schema for verification

            # Write the DataFrame to Iceberg format in the Glue Catalog
            write_to_iceberg(spark, df, table_name, args["GLUE_DATABASE"])
            logging.info(f"Wrote Iceberg table: {table_name}")

            del df  # Free up memory

        except Exception as e:
            logging.error(
                f"Error processing table {table_name}: {e}\n{traceback.format_exc()}"
            )
            sys.exit(1)

    logging.info("Glue ETL job completed.")

    # Stop the Spark session
    spark.stop()


if __name__ == "__main__":
    main()
