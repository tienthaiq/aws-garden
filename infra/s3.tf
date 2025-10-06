resource "aws_s3_bucket" "airflow" {
  bucket = var.airflow_config.log_bucket_name
}
