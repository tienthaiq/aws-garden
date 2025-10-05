import datetime
import logging
import pathlib

from airflow.sdk import DAG
from airflow.providers.standard.operators.empty import EmptyOperator
from airflow.providers.standard.operators.python import PythonOperator, BranchPythonOperator

logger = logging.getLogger(__name__)


def write_file(file_name: str, payload: str):
    from common.settings import BASE_PATH

    _path = pathlib.Path(BASE_PATH, file_name)
    if _path.exists():
        with _path.open("r") as file:
            content = file.read()
        logger.info("File %s exists. Content: %s", _path.absolute(), content)
        return
    else:
        with _path.open("w") as file:
            file.write(payload)
        logger.info("File %s does not exists. Creating new one.", _path.absolute())


with DAG(
    dag_id="write_local_file",
    start_date=datetime.datetime(2025, 10, 4)
) as dag:
    start = EmptyOperator(task_id="start")
    write_file = PythonOperator(
        task_id="write_file",
        python_callable=write_file,
        op_args=["hello.txt", "Hello World"]
    )
    end = EmptyOperator(task_id="end")
