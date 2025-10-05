resource "aws_ecs_cluster" "airflow_ecs_cluster" {
  name = "airflow"
  setting {
    name  = "containerInsights"
    value = "enhanced"
  }
}

resource "aws_ecs_cluster_capacity_providers" "airflow_ecs_cluster_cp" {
  cluster_name       = aws_ecs_cluster.airflow_ecs_cluster.name
  capacity_providers = ["FARGATE"]
}

resource "aws_ecs_task_definition" "ecs_task_def_airflow_apiserver" {
  family             = "airflow-apiserver"
  cpu                = 4096
  memory             = 8192
  execution_role_arn = aws_iam_role.ecs_task_exec_role_airflow.arn
  task_role_arn      = aws_iam_role.ecs_task_role_airflow.arn
  network_mode       = "awsvpc"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  requires_compatibilities = ["FARGATE"]
  volume {
    name                = "dag-vol"
    configure_at_launch = false
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.airflow_shared_vol.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.airflow_shared_vol_ac_dag.id
        iam             = "ENABLED"
      }
    }
  }
  container_definitions = jsonencode([
    {
      name      = "init-db"
      image     = local.airflow_image
      essential = false
      command   = ["version"]
      environment = concat(
        local.airflow_common_environment,
        [
          {
            name  = "_AIRFLOW_DB_MIGRATE"
            value = "true"
          },
        ]
      )
      user = "${local.airflow_uid}:0"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.airflow_ecs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "init-db"
        }
      }
    },
    {
      name  = "apiserver"
      image = local.airflow_image
      portMappings = [
        {
          name          = "api-server"
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      healthcheck = {
        command = ["CMD", "curl", "--fail", "http://localhost:8080/api/v2/version"]
        inteval = 35
        timeout = 30
        retries = 5
      }
      essential   = true
      command     = ["api-server"]
      environment = local.airflow_common_environment
      user        = "${local.airflow_uid}:0"
      dependsOn = [
        {
          containerName = "init-db"
          condition     = "COMPLETE"
        }
      ]
      # To reap zombie process when using ECS Exec
      # Ref: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html#ecs-exec-considerations
      linuxParameters = {
        initProcessEnabled = true
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.airflow_ecs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "apiserver"
        }
      }
      mountPoints = [
        {
          containerPath = "opt/airflow/dags"
          readOnly      = true
          sourceVolume  = "dag-vol"
        }
      ]
    },
    {
      name  = "scheduler"
      image = local.airflow_image
      healthcheck = {
        command     = ["CMD", "curl", "--fail", "http://localhost:8974/health"]
        inteval     = 35
        timeout     = 30
        retries     = 5
        startPeriod = 120
      }
      essential   = false
      command     = ["scheduler"]
      environment = local.airflow_common_environment
      user        = "${local.airflow_uid}:0"
      dependsOn = [
        {
          containerName = "init-db"
          condition     = "COMPLETE"
        }
      ]
      linuxParameters = {
        initProcessEnabled = true
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.airflow_ecs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "scheduler"
        }
      }
      mountPoints = [
        {
          containerPath = "opt/airflow/dags"
          readOnly      = true
          sourceVolume  = "dag-vol"
        }
      ]
    },
    {
      name  = "dag-processor"
      image = local.airflow_image
      healthcheck = {
        command     = ["CMD-SHELL", "airflow jobs check --job-type DagProcessorJob --hostname \"$${HOSTNAME}\""]
        inteval     = 35
        timeout     = 30
        retries     = 5
        startPeriod = 120
      }
      essential   = false
      command     = ["dag-processor"]
      environment = concat(
        local.airflow_common_environment,
        [
          {
            name  = "AIRFLOW__LOGGING__LOGGING_LEVEL"
            value = "DEBUG"
          }
        ]
      )
      user        = "${local.airflow_uid}:0"
      dependsOn = [
        {
          containerName = "init-db"
          condition     = "COMPLETE"
        }
      ]
      linuxParameters = {
        initProcessEnabled = true
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.airflow_ecs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "dag-processor"
        }
      }
      mountPoints = [
        {
          containerPath = "opt/airflow/dags"
          readOnly      = false
          sourceVolume  = "dag-vol"
        }
      ]
    },
    {
      name  = "triggerer"
      image = local.airflow_image
      healthcheck = {
        command     = ["CMD-SHELL", "airflow jobs check --job-type TriggererJob --hostname \"$${HOSTNAME}\""]
        inteval     = 35
        timeout     = 30
        retries     = 5
        startPeriod = 120
      }
      essential   = false
      command     = ["triggerer"]
      environment = local.airflow_common_environment
      user        = "${local.airflow_uid}:0"
      dependsOn = [
        {
          containerName = "init-db"
          condition     = "COMPLETE"
        }
      ]
      linuxParameters = {
        initProcessEnabled = true
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.airflow_ecs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "triggerer"
        }
      }
      mountPoints = [
        {
          containerPath = "opt/airflow/dags"
          readOnly      = true
          sourceVolume  = "dag-vol"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "airflow_apiserver" {
  name            = "airflow-apiserver"
  task_definition = aws_ecs_task_definition.ecs_task_def_airflow_apiserver.arn
  cluster         = aws_ecs_cluster.airflow_ecs_cluster.arn
  deployment_controller {
    type = "ECS"
  }
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  lifecycle {
    ignore_changes = [desired_count]
  }
  enable_execute_command = true
  launch_type            = "FARGATE"
  network_configuration {
    subnets = [
      aws_subnet.demo_airflow_subnet_public_a.id,
      aws_subnet.demo_airflow_subnet_public_b.id,
    ]
    assign_public_ip = true
    security_groups  = [aws_security_group.airflow_apiserver_sg.id]
  }
  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  # force_new_deployment = true
  load_balancer {
    target_group_arn = aws_lb_target_group.airflow_lb_target_group.arn
    container_name   = "apiserver"
    container_port   = 8080
  }
  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.airflow_apiserver_private.arn
    service {
      port_name = "api-server"
      client_alias {
        port     = 80
        dns_name = "airflow-apiserver"
      }
    }
  }
}

resource "aws_ecs_task_definition" "ecs_task_def_airflow_worker" {
  family             = "airflow-worker"
  cpu                = 2048
  memory             = 4096
  execution_role_arn = aws_iam_role.ecs_task_exec_role_airflow.arn
  task_role_arn      = aws_iam_role.ecs_task_role_airflow.arn
  network_mode       = "awsvpc"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  requires_compatibilities = ["FARGATE"]
  volume {
    name                = "dbt-vol"
    configure_at_launch = false
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.airflow_shared_vol.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.airflow_shared_vol_ac_dbt.id
        iam             = "ENABLED"
      }
    }
  }
  volume {
    name                = "dag-vol"
    configure_at_launch = false
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.airflow_shared_vol.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.airflow_shared_vol_ac_dag.id
        iam             = "ENABLED"
      }
    }
  }
  container_definitions = jsonencode([
    {
      name      = "worker"
      image     = local.airflow_image
      essential = true
      command   = ["celery", "worker"]
      environment = concat(
        local.airflow_common_environment,
        # https://airflow.apache.org/docs/docker-stack/entrypoint.html#signal-propagation
        [
          {
            name  = "DUMB_INIT_SETSID"
            value = "0"
          },
          {
            name  = "AIRFLOW__API__BASE_URL"
            value = "http://airflow-apiserver"
          }
        ]
      )
      user = "${local.airflow_uid}:0"
      linuxParameters = {
        initProcessEnabled = true
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.airflow_ecs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "worker"
        }
      }
      mountPoints = [
        {
          containerPath = "/opt/dbt"
          readOnly      = false
          sourceVolume  = "dbt-vol"
        },
        {
          containerPath = "opt/airflow/dags"
          readOnly      = true
          sourceVolume  = "dag-vol"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "airflow_worker" {
  name            = "airflow-worker"
  task_definition = aws_ecs_task_definition.ecs_task_def_airflow_worker.arn
  cluster         = aws_ecs_cluster.airflow_ecs_cluster.arn
  deployment_controller {
    type = "ECS"
  }
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  lifecycle {
    ignore_changes = [desired_count]
  }
  enable_execute_command = true
  launch_type            = "FARGATE"
  # force_new_deployment   = true
  network_configuration {
    subnets = [
      aws_subnet.demo_airflow_subnet_public_a.id,
      aws_subnet.demo_airflow_subnet_public_b.id,
    ]
    assign_public_ip = true
    security_groups  = [aws_security_group.airflow_worker_sg.id]
  }
  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.airflow_apiserver_private.arn
  }
}
