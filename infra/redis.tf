resource "aws_elasticache_subnet_group" "private_subnet_group" {
  name = "private-subnet-group"
  subnet_ids = [
    aws_subnet.demo_airflow_subnet_private_a.id,
    aws_subnet.demo_airflow_subnet_private_b.id,
  ]
}

resource "aws_elasticache_cluster" "airflow_redis" {
  cluster_id           = "airflow-redis"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  security_group_ids   = [aws_security_group.airflow_redis_sg.id]
  subnet_group_name    = aws_elasticache_subnet_group.private_subnet_group.name
}
