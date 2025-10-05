resource "aws_lb" "airflow_lb" {
  name               = "airflow-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.airflow_alb_sg.id]
  subnets = [
    aws_subnet.demo_airflow_subnet_public_a.id,
    aws_subnet.demo_airflow_subnet_public_b.id,
  ]
  ip_address_type = "ipv4"
}

resource "aws_lb_target_group" "airflow_lb_target_group" {
  name        = "airflow-lb-target-group"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.demo_airflow_vpc.id
  health_check {
    enabled             = true
    path                = "/api/v2/version"
    interval            = 30
    timeout             = 10
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "airflow_alb_listener" {
  load_balancer_arn = aws_lb.airflow_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.airflow_lb_target_group.arn
  }
}
