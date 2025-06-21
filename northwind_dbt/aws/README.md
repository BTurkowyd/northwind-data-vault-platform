# Northwind Data Vault – AWS dbt Project

This directory contains a [dbt](https://www.getdbt.com/) project implementing a Data Vault 2.0 model for the Northwind sample database, designed to run on AWS (Athena and Iceberg).

## Project Structure

- **models/**
  - **staging/**: Staging models that extract and standardize raw source data, adding metadata such as `record_source`.
  - **data_vault/**
    - **hubs/**: Hub tables for core business keys (e.g., customers, products, orders).
    - **links/**: Link tables representing relationships between hubs (e.g., order-product, customer-type).
    - **satellites/**: Satellite tables storing descriptive attributes and history for hubs and links.
  - **marts/**: Business marts for analytics, aggregating and exposing facts (e.g., sales by customer, product, region).
- **macros/**: Custom dbt macros for automation (e.g., tagging columns, generating external tables).
- **seeds/**, **snapshots/**, **analyses/**, **tests/**: Standard dbt directories for additional data and testing.
- **target/**: dbt build artifacts and logs.
- **dbt_project.yml**: Main project configuration.
- **packages.yml**: dbt package dependencies (e.g., `dbt_utils`).

## AWS & Athena Configuration

- Uses the [dbt-athena-adapter](https://github.com/dbt-athena/dbt-athena) for running models on AWS Athena.
- Data is stored in Iceberg tables, supporting incremental and merge strategies.
- S3 is used as the data lake storage backend.
- The `profiles.yml` file in `.dbt/` configures connection details (S3 staging dir, region, database, schema, workgroup).

## Data Vault Implementation

- **Hubs**: Central business entities (e.g., customers, products, orders).
- **Links**: Relationships between hubs (e.g., which customer placed which order).
- **Satellites**: Descriptive and historical attributes for hubs and links.

## Marts

- Analytical tables aggregating sales and performance metrics by customer, product, employee, region, and time.
- Designed for reporting and BI use cases.

## Macros

- Includes macros for:
  - Applying column-level tags (e.g., PII, sensitivity) to models.
  - Generating and managing external tables for Snowflake integration.

## How to Use

1. **Install dependencies**
   ```sh
   dbt deps
   ```

2. **Run models**
   ```sh
   dbt run
   ```

3. **Test models**
   ```sh
   dbt test
   ```

4. **View documentation**
   ```sh
   dbt docs generate
   dbt docs serve
   ```

## Resources

- [dbt Documentation](https://docs.getdbt.com/docs/introduction)
- [dbt Discourse](https://discourse.getdbt.com/)
- [dbt Community Slack](https://community.getdbt.com/)
- [dbt Events](https://events.getdbt.com)
- [dbt Blog](https://blog.getdbt.com/)

---

*This project is structured for extensibility and best practices in Data Vault modeling on AWS. For questions or contributions, please refer to the dbt community resources.*
