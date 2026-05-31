from pathlib import Path
import os
import subprocess

from prefect import flow, task


def _truthy(value: str | None) -> bool:
    return value is None or value.lower() not in {"0", "false", "no", "off"}


@task
def run_command(command: str, cwd: str) -> None:
    subprocess.run(command, cwd=cwd, shell=True, check=True)


@flow(name="job-market-ingest-and-dbt")
def job_market_pipeline() -> None:
    dbt_project_dir = os.getenv(
        "DBT_PROJECT_DIR",
        str(Path(__file__).resolve().parents[1]),
    )
    ingest_repo_dir = os.getenv("INGEST_REPO_DIR")
    ingest_command = os.getenv("INGEST_COMMAND")

    if _truthy(os.getenv("RUN_INGEST", "true")):
        if not ingest_repo_dir or not ingest_command:
            raise ValueError(
                "Set INGEST_REPO_DIR and INGEST_COMMAND, or set RUN_INGEST=false."
            )
        run_command(ingest_command, ingest_repo_dir)

    run_command("dbt deps", dbt_project_dir)
    run_command("dbt run", dbt_project_dir)
    run_command("dbt test", dbt_project_dir)


if __name__ == "__main__":
    job_market_pipeline()
