from typing import TypedDict


class GlueJobArgs(TypedDict):
    """
    TypedDict for Glue Job Arguments.
    Defines the expected arguments passed to the Glue ETL job.
    """

    AURORA_CREDS_SECRET: str
    DESTINATION_BUCKET: str
    DESTINATION_DIRECTORY: str
    DEBUG: bool
    GLUE_DATABASE: str


class AuroraCredentials(TypedDict):
    """
    TypedDict for Aurora Credentials.
    Defines the structure of credentials retrieved from AWS Secrets Manager.
    """

    username: str
    password: str
    host: str
    port: int
    dbname: str
