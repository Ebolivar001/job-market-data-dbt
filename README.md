# job_market_data

dbt project that transforms raw job postings into normalized staging, intermediate, and mart models.

## Prerequisites

- Python 3.11+
- PostgreSQL
- Raw job postings loaded into `stg.raw_jobs` by the ingest repo

## Local development

```bash
pip install -r requirements.txt
dbt deps
dbt run
dbt test
```

Configure your Postgres connection in `~/.dbt/profiles.yml` under the `job_market_data` profile.

Optional source overrides:

- `DBT_RAW_SCHEMA` (default: `stg`)
- `DBT_RAW_JOB_POSTINGS_TABLE` (default: `raw_jobs`)

## CI

GitHub Actions runs on every push to `main` and on pull requests:

1. Starts Postgres
2. Loads the sample raw fixture from `ci/load_raw_jobs.sql`
3. Runs `dbt deps`, `dbt parse`, `dbt run`, and `dbt test`

In production, raw data is loaded by the separate ingest repo before dbt runs.

## Orchestration

The fastest local orchestration path is the Prefect flow in
`orchestration/dbt_pipeline.py`. It runs the ingestion repo first, then runs dbt.

```bash
pip install -r requirements.txt
pip install -r orchestration/requirements.txt

export INGEST_REPO_DIR="/path/to/your/ingestion-repo"
export INGEST_COMMAND="python your_ingestion_script.py"

python orchestration/dbt_pipeline.py
```

If raw data is already loaded and you only want to orchestrate dbt:

```bash
RUN_INGEST=false python orchestration/dbt_pipeline.py
```

For cross-repo CI/CD, have the ingestion repo trigger this repo after ingestion
succeeds:

```bash
curl -X POST \
  -H "Authorization: Bearer $DBT_REPO_DISPATCH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<owner>/<dbt-repo>/dispatches \
  -d '{"event_type":"ingestion-completed"}'
```

Store `DBT_REPO_DISPATCH_TOKEN` as a GitHub Actions secret in the ingestion repo.
