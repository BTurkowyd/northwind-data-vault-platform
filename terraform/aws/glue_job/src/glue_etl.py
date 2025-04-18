import sys
import logging
import traceback

from modules.helpers import (
    create_spark_session,
    get_aurora_credentials,
    get_job_arguments,
    configure_logging,
    get_jdbc_options,
)
from modules.jdbc import fetch_table_names, load_table_as_df
from modules.iceberg import write_to_iceberg


def main():
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
        logging.error(
            f"ERROR: Failed to retrieve credentials from Secrets Manager: {e}"
        )
        sys.exit(1)

    spark = create_spark_session(args)

    if debug:
        logging.debug("Spark session created.")
        logging.debug(f"Current catalog: {spark.conf.get('spark.sql.defaultCatalog')}")

    # Construct JDBC URL
    jdbc_url = (
        f"jdbc:postgresql://{secrets['host']}:{secrets['port']}/{secrets['dbname']}"
    )

    # Set JDBC options
    jdbc_options = get_jdbc_options(jdbc_url, secrets)

    # Fetch the names of the tables in the Aurora database from the public schema, store them in a list.
    try:
        table_names = fetch_table_names(spark, jdbc_options)

        logging.info("Successfully fetched table names from Aurora.")
        logging.info(f"Tables in Aurora: {table_names}")
    except Exception as e:
        logging.error(f"ERROR: Failed to fetch table names from Aurora: {e}")
        sys.exit(1)

    # Load data from Aurora PostgreSQL from all tables
    for table_name in table_names:
        try:
            df = load_table_as_df(spark, table_name, jdbc_options)
            logging.info(f"Successfully loaded data from {table_name}.")
            df.printSchema()  # Verify the schema

            write_to_iceberg(spark, df, table_name, args["GLUE_DATABASE"])
            logging.info(f"Wrote Iceberg table: {table_name}")

            del df  # Delete the DataFrame to free up memory

        except Exception as e:
            logging.error(
                f"Error processing table {table_name}: {e}\n{traceback.format_exc()}"
            )
            sys.exit(1)

    logging.info("Glue ETL job completed.")

    # End of script
    spark.stop()


if __name__ == "__main__":
    main()
