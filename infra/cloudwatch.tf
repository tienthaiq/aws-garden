resource "aws_cloudwatch_log_group" "airflow_ecs" {
  name              = "airflow-ecs"
  retention_in_days = 1
}
