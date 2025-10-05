resource "aws_ecr_repository" "airflow" {
  name                 = "airflow"
  force_delete         = true
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
