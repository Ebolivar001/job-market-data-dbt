from pathlib import Path
import os
import subprocess

from prefect import flow, get_run_logger, task


def _truthy(value: str | None) -> bool:
    # Treat common false-like values as disabled
    return value is None or value.lower() not in {"0", "false", "no", "off"}


@task
def run_command(command: str, cwd: str) -> None:
    # Run a shell command from the selected project folder
    logger = get_run_logger()
    logger.info("Running command: %s", command)

    try:
        subprocess.run(command, cwd=cwd, shell=True, check=True)
    except subprocess.CalledProcessError as error:
        logger.error("Command failed: %s", command)
        raise RuntimeError(f"Pipeline command failed: {command}") from error


@flow(name="job-market-ingest-and-dbt")
def job_market_pipeline() -> None:
    logger = get_run_logger()

    # Default to this dbt project unless another path is given
    dbt_project_dir = os.getenv(
        "DBT_PROJECT_DIR",
        str(Path(__file__).resolve().parents[1]),
    )
    # The ingestion repo and command are passed through environment variables
    ingest_repo_dir = os.getenv("INGEST_REPO_DIR")
    ingest_command = os.getenv("INGEST_COMMAND")

    if _truthy(os.getenv("RUN_INGEST", "true")):
        # Require ingestion settings when ingestion is enabled
        if not ingest_repo_dir or not ingest_command:
            message = "Set INGEST_REPO_DIR and INGEST_COMMAND, or set RUN_INGEST=false."
            logger.error(message)
            raise ValueError(message)
        run_command(ingest_command, ingest_repo_dir)

    # Run dbt after ingestion is completed
    run_command("dbt deps", dbt_project_dir)
    run_command("dbt run", dbt_project_dir)
    run_command("dbt test", dbt_project_dir)


if __name__ == "__main__":
    job_market_pipeline()
