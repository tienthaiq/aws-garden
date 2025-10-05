resource "aws_vpc" "demo_airflow_vpc" {
  cidr_block = "10.1.0.0/21"
  enable_dns_hostnames = true
  tags = {
    Name = "demo_airflow_vpc"
  }
}

resource "aws_internet_gateway" "demo_airflow_igw" {
  vpc_id = aws_vpc.demo_airflow_vpc.id
  tags = {
    Name = "demo_airflow_igw"
  }
}

resource "aws_default_route_table" "demo_airflow_default_rtb" {
  default_route_table_id = aws_vpc.demo_airflow_vpc.main_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_airflow_igw.id
  }
  tags = {
    Name = "demo_airflow_default_rtb"
  }
}

resource "aws_subnet" "demo_airflow_subnet_public_a" {
  availability_zone       = "${var.region}a"
  cidr_block              = "10.1.0.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.demo_airflow_vpc.id
  tags = {
    Name = "demo_airflow_subnet_public_a"
  }
}

resource "aws_subnet" "demo_airflow_subnet_public_b" {
  availability_zone       = "${var.region}b"
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.demo_airflow_vpc.id
  tags = {
    Name = "demo_airflow_subnet_public_b"
  }
}

resource "aws_subnet" "demo_airflow_subnet_private_a" {
  availability_zone       = "${var.region}a"
  cidr_block              = "10.1.3.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.demo_airflow_vpc.id
  tags = {
    Name = "demo_airflow_subnet_private_a"
  }
}

resource "aws_subnet" "demo_airflow_subnet_private_b" {
  availability_zone       = "${var.region}b"
  cidr_block              = "10.1.4.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.demo_airflow_vpc.id
  tags = {
    Name = "demo_airflow_subnet_private_b"
  }
}
