import pytest
from unittest.mock import MagicMock
from modules.iceberg import write_to_iceberg


# Fixture for a mock Spark session
@pytest.fixture
def mock_spark():
    mock = MagicMock()
    mock.sql = MagicMock()
    return mock


# Fixture for a mock DataFrame
@pytest.fixture
def mock_df():
    return MagicMock()


def test_write_to_iceberg_invokes_temp_view_and_sql(mock_spark, mock_df):
    """Test that the function creates a temporary view and invokes SQL"""
    write_to_iceberg(mock_spark, mock_df, "my_table", "my_db")

    mock_df.createOrReplaceTempView.assert_called_once_with("tmp_my_table")
    mock_spark.sql.assert_called_once()
    query = mock_spark.sql.call_args[0][0]
    assert "CREATE TABLE IF NOT EXISTS glue_catalog.my_db.my_table" in query
    assert "USING iceberg" in query
    assert "TBLPROPERTIES ('format-version' = '2')" in query
    assert "SELECT * FROM tmp_my_table" in query


@pytest.mark.parametrize(
    "invalid_table", ["", "123table", "bad-name!", "with space", None]
)
def test_invalid_table_name_raises(mock_spark, mock_df, invalid_table):
    """Test that invalid table names raise ValueError"""
    with pytest.raises(ValueError, match="Invalid table name"):
        write_to_iceberg(mock_spark, mock_df, invalid_table, "analytics")


@pytest.mark.parametrize("invalid_db", ["", "123db", "invalid-db!", "with space", None])
def test_invalid_db_name_raises(mock_spark, mock_df, invalid_db):
    """Test that invalid database names raise ValueError"""
    with pytest.raises(ValueError, match="Invalid database name"):
        write_to_iceberg(mock_spark, mock_df, "valid_table", invalid_db)
