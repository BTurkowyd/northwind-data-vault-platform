# Northwind Data Vault – Snowflake dbt Project

This directory contains a [dbt](https://www.getdbt.com/) project implementing a Data Vault 2.0 model for the Northwind sample database, designed to run on Snowflake and integrate with external Iceberg tables.

## Project Structure

- **models/marts/**: Exposes business marts as Snowflake tables, each selecting from an external Iceberg table (e.g., `mart_sales`, `mart_customer_sales`, `mart_product_sales`, etc.).
- **macros/**: Custom dbt macros for automation, including:
  - `apply_column_tags_for_all_models.sql`: Applies column-level tags (e.g., PII, sensitivity) to all models.
  - `snowflake_generate_from_catalog.sql`: Generates and creates external Snowflake tables for all Iceberg marts defined in the dbt catalog.
- **analyses/**, **seeds/**, **snapshots/**, **tests/**: Standard dbt directories for additional data and testing.
- **.dbt/**: Contains your dbt profile and connection configuration.
- **dbt_project.yml**: Main project configuration.
- **packages.yml**: dbt package dependencies (e.g., `dbt_utils`).

## Snowflake & External Table Integration

- Uses the [dbt-snowflake](https://docs.getdbt.com/reference/warehouse-profiles/snowflake-profile) adapter.
- Marts are exposed as Snowflake tables that select from external Iceberg tables (created via macros).
- External tables are defined in the `external_tables` source in `schema.yml`.
- Column-level metadata (PII, sensitivity) is managed via macros and the model YAML.

## How to Use

1. **Install dependencies**
   ```sh
   dbt deps
   ```

2. **Configure your Snowflake profile**
   Edit `.dbt/profiles.yml` with your Snowflake account and authentication details.

3. **Run models**
   ```sh
   dbt run
   ```

4. **Test models**
   ```sh
   dbt test
   ```

5. **Generate and refresh external tables**
   Use the provided macros to generate and refresh external tables as needed.

6. **View documentation**
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

*This project is structured for extensibility and best practices in Data Vault modeling on Snowflake, with external table integration for Iceberg data. For questions or contributions, please refer to the dbt community resources above.*
