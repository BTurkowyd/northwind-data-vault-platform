import json
import logging
import sys
from pyspark.sql import SparkSession
import boto3
from awsglue.utils import getResolvedOptions  # type: ignore
from .typedict import GlueJobArgs, AuroraCredentials


def create_spark_session(args: GlueJobArgs) -> SparkSession:
    """
    Create a Spark session with the specified configurations.

    Args:
        args (dict): A dictionary containing the necessary configurations for the Spark session.

    Returns:
        SparkSession: The configured Spark session.
    """
    # Create a Spark session with Glue Catalog
    spark = (
        SparkSession.builder.config(
            "spark.sql.catalog.glue_catalog", "org.apache.iceberg.spark.SparkCatalog"
        )
        .config(
            "spark.sql.catalog.glue_catalog.warehouse",
            f"s3://{args['DESTINATION_BUCKET']}/{args['DESTINATION_DIRECTORY']}",
        )
        .config(
            "spark.sql.catalog.glue_catalog.catalog-impl",
            "org.apache.iceberg.aws.glue.GlueCatalog",
        )
        .config(
            "spark.sql.catalog.glue_catalog.io-impl",
            "org.apache.iceberg.aws.s3.S3FileIO",
        )
        .config(
            "spark.sql.extensions",
            "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions",
        )
        .getOrCreate()
    )

    return spark


def get_aurora_credentials(secret_name: str) -> AuroraCredentials:
    """
    Retrieve Aurora credentials from AWS Secrets Manager.

    Args:
        secret_name (str): The name of the secret in AWS Secrets Manager.

    Returns:
        dict: The retrieved Aurora credentials.
    """
    client = boto3.client("secretsmanager", region_name="eu-central-1")
    secret = client.get_secret_value(SecretId=secret_name)
    secrets = json.loads(secret["SecretString"])
    return secrets


def get_job_arguments() -> GlueJobArgs:
    """
    Retrieve job arguments passed to the Glue job.

    Returns:
        dict: A dictionary containing the job arguments.
    """
    return getResolvedOptions(
        sys.argv,
        [
            "AURORA_CREDS_SECRET",
            "DESTINATION_BUCKET",
            "DESTINATION_DIRECTORY",
            "DEBUG",
            "GLUE_DATABASE",
        ],
    )


def configure_logging(debug: bool, args: GlueJobArgs) -> None:
    """
    Configure logging for the Glue job.
    :param debug: The debug flag indicating whether to enable debug logging.
    :param args: The arguments passed to the Glue job.
    """
    if debug:
        logging.debug(f"DEBUG: {debug}")

        logging.debug(f"ARGS: {args}")
        logging.debug(f"Secrets Manager Secret: {args['AURORA_CREDS_SECRET']}")
        logging.debug(f"Destination Bucket: {args['DESTINATION_BUCKET']}")
        logging.debug(f"Destination Directory: {args['DESTINATION_DIRECTORY']}")

        logging.basicConfig(
            level=logging.DEBUG,
            format="%(asctime)s | %(levelname)s | %(filename)s:%(lineno)d | %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S",
        )
    else:
        logging.basicConfig(
            level=logging.INFO,
            format="%(asctime)s | %(levelname)s | %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S",
        )
