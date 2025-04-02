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
---

## 🔧 Infrastructure Setup and Tools

### 📦 Tools You’ll Need

Make sure you have the following installed:

- [Python 3.8+](https://www.python.org/downloads/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [tenv](https://github.com/tofuutils/tenv) – A CLI tool to easily install and manage versions of:
  - [Terraform](https://developer.hashicorp.com/terraform)
  - [Terragrunt](https://terragrunt.gruntwork.io/)
  - [OpenTofu (optional, but recommended)](https://opentofu.org/)
- [dbt CLI](https://docs.getdbt.com/docs/core/cli/installation)
- A working AWS account with sufficient permissions (IAM, VPC, Glue, RDS, etc.)

> 🧭 **Region:** This project is configured for the `eu-central-1` region by default.  
> 🏗️ **Environment:** All Terraform modules are structured per environment (e.g., `dev`, `prod`), and the working example uses `dev`.

---

### 🛠️ Infrastructure Overview

This project provisions the following infrastructure using Terraform + Terragrunt:

- **VPC with Public & Private Subnets**  
  👉 Provides network isolation and control over traffic routing.

- **NAT Gateway + VPC Endpoints**  
  👉 Ensures secure, private connectivity to AWS services (Glue, S3, Secrets Manager, etc.) from private subnets.

- **Aurora PostgreSQL Cluster**  
  👉 Acts as the operational source database for ingestion.

- **S3 Buckets**  
  - Iceberg table storage
  - Athena query results
  - Glue ETL scripts

- **AWS Glue Jobs**  
  👉 Responsible for transforming and exporting data from Aurora to Iceberg tables.
  - Glue version: `4.0`
  - Worker type: `G.1X`
  - Number of workers: `2`
  - Script stored in S3
  - Integrated with Secrets Manager and Data Catalog

- **Glue Data Catalog**  
  👉 Configured to manage Apache Iceberg tables (partitioned, versioned, and incremental).

- **IAM Roles and Policies**  
  👉 Fine-grained access for Glue, S3, Secrets Manager, and other services.

---

### 🚀 Deploying the Infrastructure

To spin up the infrastructure, navigate to the appropriate environment folder (e.g., `terragrunt/dev`) and run:

```bash
terragrunt init
terragrunt apply
```

---
### 💾 State Management & Best Practices
- Terraform State: 
  - Stored remotely using S3 and DynamoDB to enable team collaboration and avoid state conflicts.
  (You can customize this if you use a different backend setup.)
- Cost Control Tips:
  - Services like AWS Glue, Aurora, and NAT Gateway can be costly.
  - Use Aurora Serverless v2, minimal worker types for Glue, and enable auto-pause where possible.
  - Clean up dev/test environments when idle to avoid unexpected charges.
- Infrastructure Change Workflow:
  - Always preview changes before applying `terragrunt plan`.

---
## Loading Data into Aurora PostgreSQL
- This is a one-time setup to load sample data into the Aurora PostgreSQL database, therefore it is done manually directly from the AWS console:
  - Navigate to the RDS Console
  - Go to Query Editor, select the Aurora PostgreSQL instance, secret from Secrets Manager, and connect.
  - Use the SQL query from https://github.com/pthom/northwind_psql/blob/master/northwind.sql
  - Verify that the data is loaded successfully.

### 📊 Data Source: Northwind Database
- The Northwind database is a sample database used for learning SQL and data warehousing concepts.
- It contains tables for customers, orders, products, and other entities typically found in a transactional system.
- Below is a diagram of the Northwind database schema:
![Northwind ER Diagram](https://github.com/pthom/northwind_psql/blob/master/ER.png?raw=true)
---
## 🔁 ETL Pipeline: Extract, Transform, Load

This project uses **AWS Glue** and **Apache Iceberg** to extract data from an **Aurora PostgreSQL** database and store it in an Iceberg-based data lake on **S3**.

### 📦 ETL Flow Summary

1. **Extract**:  
   AWS Glue connects to the Aurora PostgreSQL instance using JDBC. Secrets are securely retrieved from AWS Secrets Manager.

2. **Transform**:  
   Glue reads data using Spark and applies any lightweight transformations if needed.

3. **Load**:  
   Data is written into Iceberg tables stored in S3, with metadata tracked in the AWS Glue Data Catalog.

---

### 🚀 Running the ETL Job

Once your infrastructure and source DB are set up, you can trigger the ETL job manually from the AWS Console, or via CLI:

```bash
aws glue start-job-run --job-name northwind-iceberg-aurora-to-s3-etl-dev
```

---
## 🧱 Data Modeling with dbt & Data Vault 2.0

Once raw data from Aurora is loaded into S3 Iceberg tables, we use **dbt** to transform it into a well-modeled Data Vault structure.

### 📐 Data Vault Components

This project uses standard Data Vault layers:

- **Hubs** – core business entities (e.g., customers, products)
- **Links** – relationships between hubs (e.g., order items link customers and products)
- **Satellites** – descriptive attributes and historical data for hubs and links

---
### 🛠️ How It's Structured

- **`models/staging/`**: Source staging models (`stg_*`) loaded from raw Iceberg tables
- **`models/data_vault/hub_*.sql`**: Hubs with business keys and surrogate keys
- **`models/data_vault/link_*.sql`**: Links joining two or more hubs
- **`models/data_vault/sat_*.sql`**: Satellites with historical attributes and hashdiffs

`dbt_utils.generate_surrogate_key()` is used for consistency in hash-based keys and change detection.

---
### 🧠 Data Vault Features Implemented

- **Incremental materializations** – Improve performance and reduce cost by only processing new or changed records.
- **Hashdiff tracking in satellites** – Enables Slowly Changing Dimension (SCD) Type 2 behavior by tracking historical changes.
- **Surrogate keys** – Simplify joins, enable deduplication, and enforce uniqueness across hubs, links, and satellites.
- **Partitioning by date in Iceberg** – Automatically handled through dbt + Glue, optimizing query performance and storage.

---
### 🧪 Running dbt

Install dbt dependencies and run the models:

```bash
dbt deps        # installs dbt_utils
dbt seed        # optional, if seeds are defined
dbt run         # builds all models
dbt run --full-refresh   # full rebuild (use carefully)
dbt docs generate        # generate documentation
dbt docs serve           # view documentation
```
