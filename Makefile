# Install python venv in .venv. Install dbt, dbt-athena-community in venv.
setup-data-vault:
	python3. -m venv .venv
	. .venv/bin/activate && pip install dbt dbt-athena-community

# Run dbt default run.
dbt-run:
	@if [ -z "$(PROJECT_DIR)" ]; then \
		echo "Error: PROJECT_DIR variable is required. Usage: make dbt-run PROJECT_DIR=project_dir"; \
		exit 1; \
	fi
	@echo "✅ Creating table: $(TABLE)"
	. .venv/bin/activate && dbt run --project-dir $(PROJECT_DIR)

# Run dbt full refresh
dbt-run-full-refresh:
	@if [ -z "$(PROJECT_DIR)" ]; then \
		echo "Error: PROJECT_DIR variable is required. Usage: make dbt-run-full-refresh PROJECT_DIR=project_dir"; \
		exit 1; \
	fi
	. .venv/bin/activate && dbt run --full-refresh --project-dir $(PROJECT_DIR)

# Generate and serve dbt documentation
dbt-documentation:
	@if [ -z "$(PROJECT_DIR)" ]; then \
		echo "Error: PROJECT_DIR variable is required. Usage: make dbt-documentation PROJECT_DIR=project_dir"; \
		exit 1; \
	fi
	. .venv/bin/activate && dbt docs generate --project-dir $(PROJECT_DIR)
	. .venv/bin/activate && dbt docs serve --project-dir $(PROJECT_DIR)