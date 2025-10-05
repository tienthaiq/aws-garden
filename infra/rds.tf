resource "aws_db_subnet_group" "airflow_db_subnet_group" {
  name = "airflow_db_subnet_group"
  subnet_ids = [
    aws_subnet.demo_airflow_subnet_private_a.id,
    aws_subnet.demo_airflow_subnet_private_b.id,
  ]

}

resource "aws_db_instance" "airflow_db" {
  identifier             = "airflow-db"
  allocated_storage      = 10
  max_allocated_storage  = 20
  db_subnet_group_name   = aws_db_subnet_group.airflow_db_subnet_group.name
  engine                 = "postgres"
  engine_version         = "17"
  instance_class         = "db.t4g.micro"
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.airflow_db_sg.id]
  apply_immediately      = true
  skip_final_snapshot    = true
  db_name                = var.airflow_db_creds.db_name
  username               = var.airflow_db_creds.username
  password               = var.airflow_db_creds.password
  port                   = var.airflow_db_creds.port
}
