# Experiments on AWS

## Airflow on ECS

### 1. Create admin user
By default, there is no user on Airflow yet, so we have to create one with admin role:

* 1. Log into `apiserver` container using ECS Exec
* 2. Log into Airflow user by running `su airflow`
* 3. Run Airflow command to create admin user

```sh
airflow users create \
    --username admin \
    --firstname Peter \
    --lastname Parker \
    --role Admin \
    --email spiderman@superhero.org
```

### 2. Create Git connection for DAG pulling
For Airflow to pull DAG bundle from Git repository, a connection with name `dag_github` must be created with Github PAT:

* 1. Log into Airflow UI as admin
* 2. Navigate to `Admin` -> `Connection`. Click to create a new one:
  * Connection ID: dag_github
  * Connection type: GIT
  * Repository URL: HTTPS URL of your repository containing dags
  * Username: Personal access token name
  * Password: Personal access token value

### 3. Create S3 connection for remote logging
For Airflow to upload log into S3, we need to create a AWS connection with name `airflow_remote_log`:

* 1. Log into Airflow UI as admin
* 2. Navigate to `Admin` -> `Connection`. Click to create a new one:
  * Connection ID: airflow_remote_log
  * Connection type: AWS
  * Access key: ignore, as we are using attached IAM role
  * Secret key: ignore, as we are using attached IAM role
  * Extra: {"region": "aws-region-of-your-bucket"}

### 4. Limitation

* Cannot use other secret backend other than Airflow metastore, because dag-processor has to use `airflow.secrets.metastore.MetastoreBackend` due to a bug
* Cannot perform healthcheck on workers because Celery does not support remote control when using AWS SQS as broker
