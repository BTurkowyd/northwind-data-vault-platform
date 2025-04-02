# Data Vault Analytics Platform with AWS Glue, Iceberg, and dbt
## Purpose of the Project

This project builds a modern, scalable data warehouse architecture using:
- AWS Aurora Serverless for transactional data storage as the source system
- AWS Glue & Iceberg for robust, ACID-compliant data lake storage
- dbt for implementing Data Vault 2.0 modeling
- Amazon Athena as the query engine
- Terraform for infrastructure provisioning

The goal is to demonstrate how to build a production-grade, cloud-native analytical platform for batch data processing 
and historical tracking using open standards and managed AWS services.

## Architecture Overview
```ascii
          +-----------------------+
          |     Source System     |
          |    (Aurora Postgres)  |
          +----------+------------+
                         |
                         ▼
        +-------------------------------+
        |     AWS Glue ETL (Python)     |
        | Extract from Aurora, write to |
        | Iceberg tables in S3          |
        +-------------------------------+
                         |
                         ▼
        +-------------------------------+
        |   Iceberg Tables on S3        |
        |   Raw Layer (Partitioned)     |
        +-------------------------------+
                         |
                         ▼
        +-------------------------------+
        |       dbt (Data Vault)        |
        | Hubs, Links, Satellites       |
        | Query via Athena              |
        +-------------------------------+
                         |
                         ▼
        [Coming Soon: Marts, PITs, Bridges]

```

## 🔧 Infrastructure Setup and Tools

### 📦 Tools You’ll Need

Make sure you have the following installed:

- [Python 3.8+](https://www.python.org/downloads/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [Terraform/Tofu and Terragrunt](http://github.com/tofuutils/tenv) (`tenv` is recommended as a convenient tool for installing all three tools)
- [dbt CLI](https://docs.getdbt.com/docs/core/cli/installation)
- A working AWS account (with necessary permissions)


### 📁 Infrastructure-as-Code with Terraform

The infrastructure in this project includes:

- A VPC with public and private subnets
- NAT Gateway & VPC Endpoints for Glue, S3, Secrets Manager, etc.
- Aurora PostgreSQL cluster as the source system
- AWS Glue Jobs and their associated:
  - Connections
  - IAM roles and policies
  - Security groups and subnets
- S3 buckets for:
  - Raw Iceberg table storage
  - Glue ETL scripts
  - Athena query results
- Glue Data Catalog configured for Apache Iceberg

To provision everything, run:

```bash
terraform init
terraform apply
```
