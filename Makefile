# import env variables from .env file
include .env

aws-init:
	set -a && . .env && set +a && cd terragrunt/dev/aws && terragrunt init

snowflake-init:
	set -a && . .env && set +a && cd terragrunt/dev/snowflake && terragrunt init

aws-plan:
	set -a && . .env && set +a && cd terragrunt/dev/aws && terragrunt plan

snowflake-plan:
	set -a && . .env && set +a && cd terragrunt/dev/snowflake && terragrunt plan

aws-apply:
	set -a && . .env && set +a && cd terragrunt/dev/aws && terragrunt apply

snowflake-apply:
	set -a && . .env && set +a && cd terragrunt/dev/snowflake && terragrunt apply
