from typing import TypedDict


class GlueJobArgs(TypedDict):
    """
    TypedDict for Glue Job Arguments
    """

    AURORA_CREDS_SECRET: str
    DESTINATION_BUCKET: str
    DESTINATION_DIRECTORY: str
    DEBUG: bool
    GLUE_DATABASE: str


class AuroraCredentials(TypedDict):
    """
    TypedDict for Aurora Credentials
    """

    username: str
    password: str
    host: str
    port: int
    dbname: str
