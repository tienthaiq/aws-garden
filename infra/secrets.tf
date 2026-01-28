resource "aws_secretsmanager_secret" "airflow_db_uri" {
  name = "airflow/db/uri"
}

resource "aws_secretsmanager_secret_version" "airflow_db_uri" {
  secret_id     = aws_secretsmanager_secret.airflow_db_uri.id
  secret_string = "postgresql+psycopg2://${var.airflow_db_creds.username}:${var.airflow_db_creds.password}@${aws_db_instance.airflow_db.endpoint}/${aws_db_instance.airflow_db.db_name}"
}

resource "aws_secretsmanager_secret" "airflow_fernet_key" {
  name = "airflow/core/fernet_key"
}

resource "aws_secretsmanager_secret_version" "airflow_fernet_key" {
  secret_id     = aws_secretsmanager_secret.airflow_fernet_key.id
  secret_string = var.airflow_config.fernet_key
}

resource "aws_secretsmanager_secret" "airflow_jwt_secret" {
  name = "airflow/api_auth/jwt_secret"
}

resource "aws_secretsmanager_secret_version" "airflow_jwt_secret" {
  secret_id     = aws_secretsmanager_secret.airflow_jwt_secret.id
  secret_string = var.airflow_config.api_auth__jwt_key
}

resource "aws_secretsmanager_secret" "airflow_secret_key" {
  name = "airflow/api/secret_key"
}

resource "aws_secretsmanager_secret_version" "airflow_secret_key" {
  secret_id     = aws_secretsmanager_secret.airflow_secret_key.id
  secret_string = var.airflow_config.api__secret_key
}

resource "aws_secretsmanager_secret" "airflow_celery_result_backend" {
  name = "airflow/celery/result_backend"
}

resource "aws_secretsmanager_secret_version" "airflow_celery_result_backend" {
  secret_id     = aws_secretsmanager_secret.airflow_celery_result_backend.id
  secret_string = "db+postgresql://${var.airflow_db_creds.username}:${var.airflow_db_creds.password}@${aws_db_instance.airflow_db.endpoint}/${aws_db_instance.airflow_db.db_name}"
}

resource "aws_secretsmanager_secret" "airflow_git_conn_body" {
  name = "airflow/github/token"
}

resource "aws_secretsmanager_secret_version" "airflow_git_conn_body" {
  secret_id = aws_secretsmanager_secret.airflow_git_conn_body.id
  secret_string = jsonencode({
    conn_type = "git"
    repo_url = var.airflow_dag_git.repo_url
    login = var.airflow_dag_git.token_name
    password = var.airflow_dag_git.token_value
  })
}

resource "aws_secretsmanager_secret" "airflow_admin_user" {
  name = "airflow/user/admin"
}

resource "aws_secretsmanager_secret_version" "airflow_admin_user" {
  secret_id = aws_secretsmanager_secret.airflow_admin_user.id
  secret_string = jsonencode({
    username = var.airflow_admin_user.username
    password = var.airflow_admin_user.password
  })
}
