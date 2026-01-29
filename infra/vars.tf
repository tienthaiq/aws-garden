variable "region" {
  type = string
}

variable "airflow_db_creds" {
  type = object({
    db_name  = string
    username = string
    password = string
    port     = string
  })
  sensitive = true
}

variable "airflow_config" {
  type = object({
    fernet_key        = string
    api__secret_key   = string
    api_auth__jwt_key = string
    image_tag         = string
    log_bucket_name   = string
  })
}

variable "airflow_dag_git" {
  type = object({
    repo_url = string
    token_name = string
    token_value = string
  })
}

variable "airflow_admin_user" {
  type = object({
    username = string
    password = string
  })
}

variable "home_ip" {
  type = string
}
