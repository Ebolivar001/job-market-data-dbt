# Job Market Data Transformation Layer

This is the transformation layer for the job market data project. It uses dbt to clean raw job posting data and turn it into a normalized set of analytics tables.

The pipeline starts with raw job postings, cleans the fields, separates repeated data into dimension tables, and builds a final fact table for job analysis.

## Design Decisions

### Why dbt and an ELT approach

The project uses an **ELT** approach: raw data is first loaded into PostgreSQL from the Ingestion repo, then transformed into the database with dbt. Transforming in the warehouse and keeps the logic in version-controlled SQL, lets the database do the heavy lifting, and makes every step testable and repeatable.

dbt was chosen because it organizes transformations into dependency-aware models, generates the run order automatically (via `ref()`), and ships with a built-in testing framework. SQL models are split into three layers, each with a single responsibility:

- `staging`: keeps the raw job posting data close to the source with light cleanup, mostly selecting and renaming columns. Materialized as views.
- `intermediate`: standardizes fields (trimming, casing, boolean/numeric/timestamp parsing), creates stable surrogate keys, and explodes the skills list into rows. Materialized as views.
- `mart`: builds the final normalized tables used for final star schema. Materialized as tables.

### The normalized model

The raw source is one wide, denormalized row per posting where company, location, and skills repeat across rows and the skills column holds a repeating group (a list inside one field). The mart redesigns this into a normalized, dimensional model:

- `fct_jobs`: one row per job posting (grain: `job_id`), with foreign keys to companies and locations.
- `dim_companies` : one row per company.
- `dim_locations` : one row per location/country.
- `dim_skills` : one row per skill.
- `bridge_job_skills` : connects jobs to skills, because one job can have many skills and one skill can belong to many jobs.

This satisfies the goals of **3NF**:

- **1NF** : the repeating skills group is removed; each skill becomes its own row in `bridge_job_skills`.
- **2NF / 3NF** : company and location attributes depend only on their own keys, so they are factored out into dimensions. Non-key job attributes (title, salary, flags) depend only on `job_id` and stay in the fact table. No company/location/skill value is repeated across job rows, which removes update anomalies.

Each table gets its own ID column (`company_id`, `location_id`, `job_id`). These IDs are built by running the cleaned values through `md5()`, which turns text into a short fixed code. The same value always produces the same code, so running the pipeline again gives the same IDs and the tables always join correctly. If a value is missing, it falls back to a default (shown as `Unknown`), so an ID is always created and never empty.

### The analytical (OLAP) model (Mart Models)

The mart is built as a **star schema** to be ready to use for BI dashboards:

- **Fact table:** `fct_jobs`, grain of one row per job posting (`job_id`), holding the dimension foreign keys and the measures.
- **Dimensions:** `dim_companies` (the employer), `dim_locations` (location/country), and `dim_skills` (joined via the `bridge_job_skills` bridge, since a job has many skills). A `dim_date` keyed on `job_posted_at` is the natural next addition for time-based trends.
- **Measures:** `salary_year_avg` and `salary_hour_avg`, plus counts of postings and skill mentions.

### Why Prefect for orchestration

dbt only handles the transform step. The optional Prefect flow in `orchestration/dbt_pipeline.py` ties together the full pipeline, it runs the external ingestion script (which loads the raw data) and then runs `dbt deps`, `dbt run`, and `dbt test` in order. 

Prefect was chosen because it adds logging, retries, and scheduling around plain shell commands without forcing the dbt logic to move out of SQL.

### GitHub Actions for CI

A GitHub Actions workflow (`.github/workflows/dbt-ci.yml`) runs the same dbt commands used locally against a throwaway PostgreSQL service, loading a small fixture from `ci/load_raw_jobs.sql`. This guarantees the models build and all tests pass before changes are merged.

## Execution Instructions

### 1. Set up the environment

```bash
python -m venv .venv
source .venv/bin/activate          
# Windows: .venv\Scripts\activate

pip install -r requirements.txt
dbt deps
```

### 2. Configure the dbt connection

Create a profile named `job_market_data` in `~/.dbt/profiles.yml` that points at your PostgreSQL database. For a local database this looks like:

```yaml
job_market_data:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: <your_user>
      password: <your_password>
      dbname: job_market
      schema: public
      threads: 4
```

### 3. Load the raw data

The pipeline expects raw job postings in:

```text
stg.raw_jobs
```

In a real run, the ingestion step loads this table. To try the pipeline locally with sample data, load the same fixture CI uses:

```bash
psql "postgresql://<your_user>:<your_password>@localhost:5432/job_market" -f ci/load_raw_jobs.sql
```

### 4. Run the transformations

```bash
dbt run
```

### 5. (Optional) Run the full pipeline with Prefect

To run ingestion and dbt together, point Prefect at your ingestion repo and command:

```bash
pip install -r orchestration/requirements.txt

export INGEST_REPO_DIR="/path/to/ingestion-repo"
export INGEST_COMMAND="python your_ingestion_script.py"

python orchestration/dbt_pipeline.py
```

If the raw data is already loaded and you only want to run dbt through Prefect:

```bash
RUN_INGEST=false python orchestration/dbt_pipeline.py
```

## Testing Guide

Run all dbt tests with:

```bash
dbt test
```

The tests check the data rules that keep the normalized model trustworthy:

- **Primary keys** (`company_id`, `location_id`, `skill_name`, `job_id`, `raw_row_id`) are `not_null` and `unique`, enforcing the one-row-per-entity grain.
- **Foreign keys** use `relationships` tests so `fct_jobs` and `bridge_job_skills` can never point at companies, locations, skills, or jobs that do not exist (no orphan keys).
- **Bridge uniqueness** uses `dbt_utils.unique_combination_of_columns` on `(job_id, skill_name)` to prevent duplicate job–skill edges.
- **Required fields** such as standardized company name, location, and country are `not_null`.

For a full local check that mirrors CI, run:

```bash
dbt deps
dbt parse
dbt run
dbt test
```

To run the tests for a single model, use a selector:

```bash
dbt test --select fct_jobs
```

GitHub Actions runs these same checks on pull requests and pushes to `main`. It starts PostgreSQL, loads sample raw data from `ci/load_raw_jobs.sql`, then runs the dbt commands above.
