resource "aws_service_discovery_private_dns_namespace" "airflow_apiserver_private" {
  name = "airflow-apiserver-private"
  vpc  = aws_vpc.demo_airflow_vpc.id
}
