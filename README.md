# Experiments on AWS

## Airflow on ECS

### 1. Create Git connection for DAG pulling
For Airflow to pull DAG bundle from Git repository, a connection with name `dag_github` must be created with Github PAT:

* 1. Log into Airflow UI as admin
* 2. Navigate to `Admin` -> `Connection`. Click to create a new one:
  * Connection ID: dag_github
  * Connection type: GIT
  * Repository URL: HTTPS URL of your repository containing dags
  * Username: Personal access token name
  * Password: Personal access token value

### 2. Limitation

* Cannot use other secret backend other than Airflow metastore, because dag-processor has to use `airflow.secrets.metastore.MetastoreBackend` due to a bug
* Cannot perform healthcheck on workers because Celery does not support remote control when using AWS SQS as broker
