import json
import sys
from unittest.mock import MagicMock, patch
from botocore.exceptions import ClientError
import logging

# Patch AWS Glue before import (no awsglue in local env)
sys.modules["awsglue"] = MagicMock()
sys.modules["awsglue.utils"] = MagicMock()

import pytest
from pyspark.sql import SparkSession
from modules.helpers import (
    create_spark_session,
    get_aurora_credentials,
    get_job_arguments,
    configure_logging,
)


@pytest.fixture
def args():
    return {
        "DESTINATION_BUCKET": "test-bucket",
        "DESTINATION_DIRECTORY": "test-directory",
    }


@pytest.fixture
def spark(args):
    spark = create_spark_session(args)
    yield spark
    spark.stop()


def test_create_spark_session_returns_instance(spark):
    """Test that the create_spark_session function returns a SparkSession instance."""
    assert isinstance(spark, SparkSession)


def test_create_spark_session_sets_config(spark, args):
    """Test that the create_spark_session function sets the correct Spark configuration."""
    expected_warehouse = (
        f"s3://{args['DESTINATION_BUCKET']}/{args['DESTINATION_DIRECTORY']}"
    )

    assert (
        spark.conf.get("spark.sql.catalog.glue_catalog.warehouse") == expected_warehouse
    )
    assert (
        spark.conf.get("spark.sql.catalog.glue_catalog")
        == "org.apache.iceberg.spark.SparkCatalog"
    )
    assert (
        spark.conf.get("spark.sql.catalog.glue_catalog.catalog-impl")
        == "org.apache.iceberg.aws.glue.GlueCatalog"
    )
    assert (
        spark.conf.get("spark.sql.catalog.glue_catalog.io-impl")
        == "org.apache.iceberg.aws.s3.S3FileIO"
    )
    assert (
        spark.conf.get("spark.sql.extensions")
        == "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions"
    )


def test_missing_required_arg_raises_keyerror():
    """Test that missing required arguments raises a KeyError."""
    with pytest.raises(KeyError):
        create_spark_session({"DESTINATION_BUCKET": "only-this-key"})


def test_create_spark_session_with_extra_keys(spark):
    """Test that extra keys in the args dictionary do not affect the Spark session creation."""
    args = {
        "DESTINATION_BUCKET": "bucket",
        "DESTINATION_DIRECTORY": "dir",
        "UNUSED_KEY": "should_not_break",
    }
    spark = create_spark_session(args)
    assert isinstance(spark, SparkSession)
    spark.stop()


@pytest.mark.parametrize(
    "bucket,directory",
    [
        (None, "dir"),
        ("", "dir"),
        ("bucket", None),
        ("bucket", ""),
    ],
)
def test_create_spark_session_invalid_args(bucket, directory):
    """Test that invalid arguments raise an exception."""
    args = {
        "DESTINATION_BUCKET": bucket,
        "DESTINATION_DIRECTORY": directory,
    }
    with pytest.raises(Exception):
        create_spark_session(args)


def test_get_aurora_credentials_success():
    """Test that get_aurora_credentials retrieves the correct secret from AWS Secrets Manager."""
    fake_secret_name = "my-secret"
    fake_secret_value = {
        "username": "dbuser",
        "password": "secret",
        "host": "example.com",
        "port": 5432,
        "dbname": "mydb",
    }

    with patch("boto3.client") as mock_client:
        mock_instance = MagicMock()
        mock_instance.get_secret_value.return_value = {
            "SecretString": json.dumps(fake_secret_value)
        }
        mock_client.return_value = mock_instance

        result = get_aurora_credentials(fake_secret_name)
        assert result == fake_secret_value


def test_get_aurora_credentials_not_found():
    """Test that get_aurora_credentials raises an exception when the secret is not found."""
    with patch("boto3.client") as mock_client:
        mock_instance = MagicMock()
        mock_instance.get_secret_value.side_effect = ClientError(
            {"Error": {"Code": "ResourceNotFoundException"}}, "GetSecretValue"
        )
        mock_client.return_value = mock_instance

        with pytest.raises(ClientError):
            get_aurora_credentials("nonexistent")


@patch("modules.helpers.getResolvedOptions")
def test_get_job_arguments_returns_expected_keys(mock_get_resolved_options):
    """Test that get_job_arguments returns the expected keys."""
    fake_args = {
        "AURORA_CREDS_SECRET": "secret-name",
        "DESTINATION_BUCKET": "my-bucket",
        "DESTINATION_DIRECTORY": "data",
        "DEBUG": "true",
        "GLUE_DATABASE": "analytics",
    }
    mock_get_resolved_options.return_value = fake_args

    result = get_job_arguments()
    assert result == fake_args


@patch("modules.helpers.getResolvedOptions")
def test_get_job_arguments_uses_sys_argv(mock_get_resolved_options):
    """Test that get_job_arguments uses sys.argv to get arguments."""
    sys.argv = ["glue_script.py", "--AURORA_CREDS_SECRET", "abc"]
    mock_get_resolved_options.return_value = {
        "AURORA_CREDS_SECRET": "abc",
        "DESTINATION_BUCKET": "b",
        "DESTINATION_DIRECTORY": "c",
        "DEBUG": "false",
        "GLUE_DATABASE": "db",
    }

    result = get_job_arguments()
    assert "AURORA_CREDS_SECRET" in result


def dummy_args():
    return {
        "AURORA_CREDS_SECRET": "secret",
        "DESTINATION_BUCKET": "bucket",
        "DESTINATION_DIRECTORY": "prefix",
        "DEBUG": "true",
        "GLUE_DATABASE": "db",
    }


@patch("logging.basicConfig")
@patch("logging.debug")
def test_configure_logging_debug_true(mock_debug, mock_basic_config):
    configure_logging(True, dummy_args())
    mock_basic_config.assert_called_once_with(
        level=logging.DEBUG,
        format="%(asctime)s | %(levelname)s | %(filename)s:%(lineno)d | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    assert mock_debug.call_count >= 4


@patch("logging.basicConfig")
def test_configure_logging_debug_false(mock_basic_config):
    configure_logging(False, dummy_args())
    mock_basic_config.assert_called_once_with(
        level=logging.INFO,
        format="%(asctime)s | %(levelname)s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
