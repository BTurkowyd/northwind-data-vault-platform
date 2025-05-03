from diagrams import Diagram, Cluster
from diagrams.onprem.database import Postgresql
from diagrams.aws.analytics import Glue
from diagrams.aws.storage import S3
from diagrams.programming.language import Python
from diagrams.onprem.analytics import Spark
from diagrams.generic.storage import Storage
from diagrams.saas.analytics import Snowflake
from diagrams.custom import Custom

graph_attr = {"bgcolor": "white", "style": "dotted"}

with Diagram(
    "Data Infrastructure - Logical Flow",
    show=True,
    direction="LR",
    graph_attr=graph_attr,
):
    source = Postgresql("Aurora PostgreSQL")
    etl = Glue("Glue")

    with Cluster(
        "Bronze: Raw Zone (Iceberg)", graph_attr={"bgcolor": "#E3F2FD"}
    ):  # light blue
        raw_zone = [S3("raw_customers"), S3("raw_orders"), S3("raw_products")]

    dbt = Custom("dbt / Data Vault", "./dbt_icon.png")

    with Cluster(
        "Silver: Data Vault (Iceberg)", graph_attr={"bgcolor": "#E8F5E9"}
    ):  # light green
        data_vault = [Storage("hubs"), Storage("links"), Storage("satellites")]

    dbt_marts = Custom("dbt / marts_snowflake", "./dbt_icon.png")

    with Cluster(
        "Gold: Marts (Iceberg)", graph_attr={"bgcolor": "#FFF3E0"}
    ):  # light orange
        marts = [
            Storage("mart_sales"),
            Storage("mart_product_perf"),
            Storage("mart_customers"),
        ]

    dbt_snowflake = Custom("dbt / Snowflake", "./dbt_icon.png")

    with Cluster("Snowflake", graph_attr={"bgcolor": "#F3E5F5"}):  # light purple
        snowflake_ext = Snowflake("External Tables")
        snowflake_mat = Snowflake("Materialized Tables")

    # Connections
    source >> etl
    for raw in raw_zone:
        etl >> raw >> dbt

    for layer in data_vault:
        dbt >> layer >> dbt_marts

    for mart in marts:
        dbt_marts >> mart >> dbt_snowflake
        dbt_snowflake >> snowflake_ext >> snowflake_mat
