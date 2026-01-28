# Airflow ECS task execution roles
resource "aws_iam_role" "ecs_task_exec_role_airflow" {
  name = "ecs_task_exec_role_airflow"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy" "amazon_ecs_task_exection_role_policy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_role_airflow_attachment" {
  role       = aws_iam_role.ecs_task_exec_role_airflow.name
  policy_arn = data.aws_iam_policy.amazon_ecs_task_exection_role_policy.arn
}

resource "aws_iam_policy" "ecs_task_exec_role_airflow_read_secret" {
  name = "ecs_task_exec_role_airflow_read_secret"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Effect = "Allow"
        Resource = [
          aws_secretsmanager_secret.airflow_db_uri.arn,
          aws_secretsmanager_secret.airflow_fernet_key.arn,
          aws_secretsmanager_secret.airflow_secret_key.arn,
          aws_secretsmanager_secret.airflow_jwt_secret.arn,
          aws_secretsmanager_secret.airflow_celery_result_backend.arn,
          aws_secretsmanager_secret.airflow_git_conn_body.arn,
          aws_secretsmanager_secret.airflow_admin_user.arn,
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_role_airflow_read_secret_attachment" {
  role       = aws_iam_role.ecs_task_exec_role_airflow.name
  policy_arn = aws_iam_policy.ecs_task_exec_role_airflow_read_secret.arn
}

# Airflow ECS task role
resource "aws_iam_role" "ecs_task_role_airflow" {
  name = "ecs_task_role_airflow"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "ecs_task_role_airflow_s3_policy" {
  name = "ecs_task_role_airflow_s3_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ],
        Resource = [
          aws_s3_bucket.airflow.arn,
          "${aws_s3_bucket.airflow.arn}/*",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_airflow_s3_policy_attachment" {
  role       = aws_iam_role.ecs_task_role_airflow.name
  policy_arn = aws_iam_policy.ecs_task_role_airflow_s3_policy.arn
}

resource "aws_iam_policy" "ecs_task_role_ecs_exec" {
  name = "ecs_task_role_ecs_exec"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_ecs_exec_attachment" {
  role       = aws_iam_role.ecs_task_role_airflow.name
  policy_arn = aws_iam_policy.ecs_task_role_ecs_exec.arn
}

## Uncomment if using AWS SQS broker
# resource "aws_iam_policy" "ecs_task_role_airflow_sqs_rw" {
#   name = "ecs_task_role_airflow_sqs_rw"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "sqs:ReceiveMessage",
#           "sqs:SendMessage",
#           "sqs:DeleteMessage",
#           "sqs:ChangeMessageVisibility",
#           "sqs:GetQueueAttributes",
#         ]
#         Resource = aws_sqs_queue.airflow_celery_broker.arn
#       }
#     ]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "ecs_task_role_airflow_sqs_rw_attachment" {
#   role       = aws_iam_role.ecs_task_role_airflow.name
#   policy_arn = aws_iam_policy.ecs_task_role_airflow_sqs_rw.arn
# }

resource "aws_iam_policy" "airflow_rw_efs" {
  name = "airflow_rw_efs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:DescribeMountTargets",
          "elasticfilesystem:DescribeFileSystems",
        ]
        Resource = [aws_efs_file_system.airflow_shared_vol.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_airflow_rw_efs_attachment" {
  role       = aws_iam_role.ecs_task_role_airflow.name
  policy_arn = aws_iam_policy.airflow_rw_efs.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_airflow_cloudwatch_write" {
  role       = aws_iam_role.ecs_task_role_airflow.name
  policy_arn = data.aws_iam_policy.aws_cloudwatch_agent_server_policy.arn
}
