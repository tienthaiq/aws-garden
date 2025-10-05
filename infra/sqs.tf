resource "aws_sqs_queue" "airflow_celery_broker" {
  name = "airflow_celery_broker"
}