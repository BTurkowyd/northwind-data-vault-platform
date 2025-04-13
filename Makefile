# import env variables from .env file
include .env

aws-init:
	set -a && . .env && set +a && cd terragrunt/dev/aws && terragrunt init

aws-plan:
	set -a && . .env && set +a && cd terragrunt/dev/aws && terragrunt plan

aws-apply:
	set -a && . .env && set +a && cd terragrunt/dev/aws && terragrunt apply

aws-dbt:
	set -a && . .env && set +a && cd northwind_dbt && dbt run --fail-fast --profile northwind_dbt --target dev --profiles-dir ./.dbt


snowflake-init:
	set -a && . .env && set +a && cd terragrunt/dev/snowflake && terragrunt init

snowflake-plan:
	set -a && . .env && set +a && cd terragrunt/dev/snowflake && terragrunt plan

snowflake-apply:
	set -a && . .env && set +a && cd terragrunt/dev/snowflake && terragrunt apply

snowflake-dbt:
	set -a && \
	. .env && \
	DBT_JSON_CATALOG="$$(< /Users/bartoszturkowyd/Projects/dbt-data-vault/northwind_dbt/target/catalog.json)" && \
	export DBT_JSON_CATALOG && \
	set +a && \
	cd northwind_dbt \
	&& dbt run-operation snowflake_generate_from_catalog --profile snowflake_profile --target dev --profiles-dir ./.dbt
