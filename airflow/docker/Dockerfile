FROM apache/airflow:3.1.6-python3.12

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY airflow.cfg /opt/airflow/
COPY config /opt/airflow/config
