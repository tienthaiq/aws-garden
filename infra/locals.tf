locals {
  airflow_image = "${aws_ecr_repository.airflow.repository_url}:3.1.0-build-0.0.6"
  airflow_uid   = 50000
  airflow_common_environment = [
    {
      name  = "AIRFLOW__CORE__EXECUTOR"
      value = "CeleryExecutor"
    },
    {
      name  = "AIRFLOW__CORE__AUTH_MANAGER"
      value = "airflow.providers.fab.auth_manager.fab_auth_manager.FabAuthManager"
    },
    {
      name  = "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN"
      value = "postgresql+psycopg2://${var.airflow_db_creds.username}:${var.airflow_db_creds.password}@${aws_db_instance.airflow_db.endpoint}/${aws_db_instance.airflow_db.db_name}"
    },
    {
      name  = "AIRFLOW__CORE__FERNET_KEY"
      value = var.airflow_config.fernet_key
    },
    {
      name  = "AIRFLOW__API__SECRET_KEY"
      value = var.airflow_config.api_secret_key
    },
    {
      name  = "AIRFLOW__API__WORKERS"
      value = "1"
    },
    {
      name  = "AIRFLOW__API_AUTH__JWT_SECRET"
      value = var.airflow_config.api_auth_secret_key
    },
    {
      name  = "AIRFLOW__CELERY__RESULT_BACKEND"
      value = "db+postgresql://${var.airflow_db_creds.username}:${var.airflow_db_creds.password}@${aws_db_instance.airflow_db.endpoint}/${aws_db_instance.airflow_db.db_name}"
    },
    {
      name  = "X_AIRFLOW_CELERY_SQS_BROKER_PREDEFINED_QUEUE_URL"
      value = aws_sqs_queue.airflow_celery_broker.url
    },
    {
      name  = "AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION"
      value = "true"
    },
    {
      name  = "AIRFLOW__CORE__LOAD_EXAMPLES"
      value = "false"
    },
    {
      name  = "AIRFLOW__SCHEDULER__ENABLE_HEALTH_CHECK"
      value = "true"
    },
    {
      name  = "AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER"
      value = "s3://tientq-airflow/logs"
    },
    {
      name  = "AIRFLOW__CELERY__WORKER_CONCURRENCY"
      value = "4"
    },
    {
      name  = "AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID"
      value = "airflow_remote_log"
    },
    {
      name = "AIRFLOW__DAG_PROCESSOR__DAG_BUNDLE_CONFIG_LIST"
      value = jsonencode([
        {
          name      = "dag_git_repo"
          classpath = "airflow.providers.git.bundles.git.GitDagBundle"
          kwargs = {
            tracking_ref = "main"
            subdir       = "airflow/dags"
            git_conn_id  = "dag_github"
          }
        }
      ])
    },
    {
      name = "AIRFLOW__SECRETS__BACKEND"
      value = "airflow.secrets.metastore.MetastoreBackend"
    }
  ]
}
