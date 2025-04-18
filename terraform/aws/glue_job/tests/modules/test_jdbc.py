import sys
from unittest.mock import MagicMock

# Patch AWS Glue before import (no awsglue in local env)
sys.modules["awsglue"] = MagicMock()
sys.modules["awsglue.utils"] = MagicMock()

import pytest
from pyspark.sql import Row
from modules.jdbc import get_jdbc_options, fetch_table_names, load_table_as_df


@pytest.fixture
def secrets():
    return {
        "username": "user",
        "password": "pass",
        "host": "localhost",
        "port": 5432,
        "dbname": "mydb",
    }


@pytest.fixture
def jdbc_options():
    return {
        "url": "jdbc:postgresql://localhost:5432/mydb",
        "user": "user",
        "password": "pass",
        "driver": "org.postgresql.Driver",
    }


def test_returns_expected_dict(secrets, jdbc_options):
    """Test that get_jdbc_options returns the expected dictionary."""
    jdbc_url = "jdbc:postgresql://localhost:5432/mydb"
    options = get_jdbc_options(jdbc_url, secrets)
    assert options == jdbc_options


def test_missing_username_raises(secrets):
    """Test that missing username raises KeyError."""
    del secrets["username"]
    with pytest.raises(KeyError):
        get_jdbc_options("jdbc:postgresql://localhost:5432/mydb", secrets)


def test_missing_password_raises(secrets):
    """Test that missing password raises KeyError."""
    del secrets["password"]
    with pytest.raises(KeyError):
        get_jdbc_options("jdbc:postgresql://localhost:5432/mydb", secrets)


def test_fetch_table_names_returns_expected_list(jdbc_options):
    """Test that fetch_table_names returns a list of table names."""
    mock_spark = MagicMock()
    mock_df = MagicMock()
    mock_df.collect.return_value = [Row(table_name="table1"), Row(table_name="table2")]
    mock_df.select.return_value = mock_df

    reader = MagicMock()
    reader.options.return_value.load.return_value = mock_df
    mock_spark.read.format.return_value = reader

    result = fetch_table_names(mock_spark, jdbc_options)
    assert result == ["table1", "table2"]


def test_fetch_table_names_returns_empty_list_on_no_tables(jdbc_options):
    mock_spark = MagicMock()
    mock_df = MagicMock()
    mock_df.collect.return_value = []
    mock_df.select.return_value = mock_df

    reader = MagicMock()
    reader.options.return_value.load.return_value = mock_df
    mock_spark.read.format.return_value = reader

    result = fetch_table_names(mock_spark, jdbc_options)
    assert result == []


def test_fetch_table_names_propagates_spark_error(jdbc_options):
    mock_spark = MagicMock()
    reader = MagicMock()
    reader.options.return_value.load.side_effect = Exception("Spark read failed")
    mock_spark.read.format.return_value = reader
    with pytest.raises(Exception, match="Spark read failed"):
        fetch_table_names(mock_spark, jdbc_options)


def test_fetch_table_names_ignores_unexpected_columns(jdbc_options):
    mock_spark = MagicMock()
    mock_df = MagicMock()
    mock_df.collect.return_value = [Row(table_name="abc", other="should_ignore")]
    mock_df.select.return_value = mock_df

    reader = MagicMock()
    reader.options.return_value.load.return_value = mock_df
    mock_spark.read.format.return_value = reader

    result = fetch_table_names(mock_spark, jdbc_options)
    assert result == ["abc"]


def test_load_table_as_df_returns_dataframe(jdbc_options):
    mock_spark = MagicMock()
    mock_df = MagicMock()

    reader = MagicMock()
    reader.options.return_value.load.return_value = mock_df
    mock_spark.read.format.return_value = reader

    result = load_table_as_df(mock_spark, "users", jdbc_options)
    assert result == mock_df
    reader.options.assert_called_once_with(
        url="jdbc:postgresql://localhost:5432/mydb",
        user="user",
        password="pass",
        driver="org.postgresql.Driver",
        dbtable="users",
    )


@pytest.mark.parametrize(
    "bad_name", ["", "   ", "123table", "invalid-char!", "name.with.dot"]
)
def test_invalid_table_name_raises(jdbc_options, bad_name):
    mock_spark = MagicMock()

    with pytest.raises(ValueError, match=f"Invalid table name: '{bad_name}'"):
        load_table_as_df(mock_spark, bad_name, jdbc_options)


def test_load_table_as_df_propagates_spark_error(jdbc_options):
    mock_spark = MagicMock()
    reader = MagicMock()
    reader.options.return_value.load.side_effect = RuntimeError("spark read fail")
    mock_spark.read.format.return_value = reader

    with pytest.raises(RuntimeError, match="spark read fail"):
        load_table_as_df(mock_spark, "users", jdbc_options)
