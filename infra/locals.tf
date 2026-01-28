locals {
  airflow_image = "${aws_ecr_repository.airflow.repository_url}:${var.airflow_config.image_tag}"
  airflow_uid   = 50000
  airflow_secret_environment = [
    {
      name      = "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN"
      valueFrom = aws_secretsmanager_secret.airflow_db_uri.arn
    },
    {
      name      = "AIRFLOW__CORE__FERNET_KEY"
      valueFrom = aws_secretsmanager_secret.airflow_fernet_key.arn
    },
    {
      name      = "AIRFLOW__API__SECRET_KEY"
      valueFrom = aws_secretsmanager_secret.airflow_secret_key.arn
    },
    {
      name      = "AIRFLOW__API_AUTH__JWT_SECRET"
      valueFrom = aws_secretsmanager_secret.airflow_jwt_secret.arn
    },
    {
      name      = "AIRFLOW__CELERY__RESULT_BACKEND"
      valueFrom = aws_secretsmanager_secret.airflow_celery_result_backend.arn
    },
    # TODO: GitDagBundle somehow does not pick up connection from environment variable
    # {
    #   name = "AIRFLOW_CONN_DAG_GITHUB"
    #   valueFrom = aws_secretsmanager_secret.airflow_git_conn_body.arn
    # },
  ]
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
      name  = "AIRFLOW__API__WORKERS"
      value = "2"
    },
    {
      name = "AIRFLOW__CELERY__BROKER_URL"
      value = "redis://:@${aws_elasticache_cluster.airflow_redis.cache_nodes[0].address}:${aws_elasticache_cluster.airflow_redis.cache_nodes[0].port}/0"
    },
    # Uncomment if using AWS SQS broker
    # {
    #   name  = "X_AIRFLOW_CELERY_SQS_BROKER_PREDEFINED_QUEUE_URL"
    #   value = aws_sqs_queue.airflow_celery_broker.url
    # },
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
      value = "s3://${var.airflow_config.log_bucket_name}/logs"
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
      name = "AIRFLOW_CONN_AIRFLOW_REMOTE_LOG"
      value = jsonencode({
        conn_type = "aws"
        extra = jsonencode({
          region = var.region
        })
      })
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
    }
  ]
}
