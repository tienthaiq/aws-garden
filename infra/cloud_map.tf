resource "aws_service_discovery_private_dns_namespace" "airflow_private" {
  name = "airflow-private"
  vpc  = aws_vpc.demo_airflow_vpc.id
}
