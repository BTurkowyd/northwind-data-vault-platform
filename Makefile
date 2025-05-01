# Local flag (default: true)
LOCAL ?= true

# Load environment variables if LOCAL=true
ENV = $(if $(filter true,$(LOCAL)),set -a && . .env && set +a &&,)

# Paths
AWS_DIR = terragrunt/dev/aws
SNOWFLAKE_DIR = terragrunt/dev/snowflake
DBT_DIR = northwind_dbt
CATALOG_JSON = $(DBT_DIR)/target/catalog.json

# Helper for Terragrunt commands
define TG_CMD
	$(ENV) cd $1 && terragrunt $2
endef

# AWS
aws-init:
	$(call TG_CMD, $(AWS_DIR), init)

aws-plan:
	$(call TG_CMD, $(AWS_DIR), plan)

aws-apply:
	$(call TG_CMD, $(AWS_DIR), apply)

aws-dbt:
	$(ENV) cd $(DBT_DIR) && \
 	dbt deps && \
 	dbt run --fail-fast --profile northwind_dbt --target dev --profiles-dir ./.dbt && \
	dbt docs generate --profile northwind_dbt --target dev --profiles-dir ./.dbt

aws-dbt-docs:
	$(ENV) cd $(DBT_DIR) && \
	dbt docs generate --profile northwind_dbt --target dev --profiles-dir ./.dbt

aws-dbt-docs-serve:
	$(ENV) cd $(DBT_DIR) && \
	dbt docs serve --profile northwind_dbt --target dev --profiles-dir ./.dbt

# Snowflake
snowflake-init:
	$(call TG_CMD, $(SNOWFLAKE_DIR), init)

snowflake-plan:
	$(call TG_CMD, $(SNOWFLAKE_DIR), plan)

snowflake-apply:
	$(call TG_CMD, $(SNOWFLAKE_DIR), apply)

snowflake-destroy:
	$(call TG_CMD, $(SNOWFLAKE_DIR), destroy)

snowflake-dbt:
	$(ENV) \
	DBT_JSON_CATALOG="$$(cat $(CATALOG_JSON))" && \
	export DBT_JSON_CATALOG && \
	cd $(DBT_DIR) && \
	dbt deps && \
	dbt run-operation snowflake_generate_from_catalog --profile snowflake_profile --target dev --profiles-dir ./.dbt

.PHONY: aws-init aws-plan aws-apply aws-dbt snowflake-init snowflake-plan snowflake-apply snowflake-dbt
