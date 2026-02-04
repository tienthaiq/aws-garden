resource "aws_security_group" "airflow_alb_sg" {
  name   = "airflow_alb_sg"
  vpc_id = aws_vpc.demo_airflow_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.home_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "airflow_controlplane_sg" {
  name   = "airflow_controlplane_sg"
  vpc_id = aws_vpc.demo_airflow_vpc.id
  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
      aws_security_group.airflow_alb_sg.id,
      aws_security_group.airflow_worker_sg.id,
    ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "airflow_db_sg" {
  name   = "airflow_db_sg"
  vpc_id = aws_vpc.demo_airflow_vpc.id
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      aws_security_group.airflow_controlplane_sg.id,
      aws_security_group.airflow_worker_sg.id,
    ]
  }
}

resource "aws_security_group" "airflow_redis_sg" {
  name   = "airflow_redis_sg"
  vpc_id = aws_vpc.demo_airflow_vpc.id
  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    security_groups = [
      aws_security_group.airflow_controlplane_sg.id,
      aws_security_group.airflow_worker_sg.id,
    ]
  }
}

resource "aws_security_group" "airflow_worker_sg" {
  name   = "airflow_worker_sg"
  vpc_id = aws_vpc.demo_airflow_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "airflow_worker_sg_ingress" {
  security_group_id            = aws_security_group.airflow_worker_sg.id
  from_port                    = 8793
  to_port                      = 8793
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.airflow_controlplane_sg.id
}


resource "aws_security_group" "efs_airflow_shared_vol" {
  name   = "efs_airflow_shared_vol"
  vpc_id = aws_vpc.demo_airflow_vpc.id
  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    security_groups = [
      aws_security_group.airflow_worker_sg.id,
    ]
  }
}
