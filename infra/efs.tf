resource "aws_efs_file_system" "airflow_shared_vol" {
  creation_token = "airflow-shared-vol"
}

resource "aws_efs_mount_target" "airflow_shared_vol_az_a" {
  file_system_id  = aws_efs_file_system.airflow_shared_vol.id
  subnet_id       = aws_subnet.demo_airflow_subnet_public_a.id
  security_groups = [aws_security_group.efs_airflow_shared_vol.id]
}

resource "aws_efs_mount_target" "airflow_shared_vol_az_b" {
  file_system_id  = aws_efs_file_system.airflow_shared_vol.id
  subnet_id       = aws_subnet.demo_airflow_subnet_public_b.id
  security_groups = [aws_security_group.efs_airflow_shared_vol.id]
}

resource "aws_efs_access_point" "airflow_shared_vol_ac_dbt" {
  file_system_id = aws_efs_file_system.airflow_shared_vol.id
  posix_user {
    uid = local.airflow_uid
    gid = 0
  }
  root_directory {
    path = "/dbt"
    creation_info {
      owner_uid   = local.airflow_uid
      owner_gid   = 0
      permissions = 775
    }
  }
}
