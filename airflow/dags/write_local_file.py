import datetime
import logging
import pathlib

from airflow.sdk import DAG
from airflow.providers.standard.operators.empty import EmptyOperator
from airflow.providers.standard.operators.python import PythonOperator, BranchPythonOperator

BASE_PATH = "/opt/dbt"

logger = logging.getLogger(__name__)


def write_file(path: str, payload: str):
    _path = pathlib.Path(path)
    if _path.exists():
        with _path.open("r") as file:
            content = file.read()
        logger.info("File %s exists. Content: %s", path, content)
        return
    else:
        with _path.open("w") as file:
            file.write(payload)
        logger.info("File %s does not exists. Creating new one.", path)


with DAG(
    "write_local_file",
    start_date=datetime.datetime(2025, 10, 4)
) as dag:
    file_path = BASE_PATH + "/hello.txt"
    start = EmptyOperator("start")
    write_file = PythonOperator(
        "write_file",
        python_callable=write_file,
        op_args=[file_path, "Hello World"]
    )
    end = EmptyOperator("end")
