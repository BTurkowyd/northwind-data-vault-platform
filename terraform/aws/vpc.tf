# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.repo_name}-vpc"
  }
}

# Create Subnets (Aurora requires at least 2, both are private)
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.repo_name}-subnet-1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "dbt-data-vault-subnet-2"
  }
}

# Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.private_rt.id
}

# Public subnet (for Bastion Host)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-central-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.repo_name}-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.repo_name}-igw"
  }
}


# Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public_rt" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.eu-central-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.public_rt.id,
    aws_route_table.private_rt.id
  ]

  tags = {
    Name = "${var.repo_name}-s3-endpoint"
  }
}

locals {
  interface_services = [
    "secretsmanager",
    "logs",
    "glue",
  ]
}

# resource "aws_vpc_endpoint" "interface_endpoints" {
#   for_each            = toset(local.interface_services)
#   vpc_id              = aws_vpc.main.id
#   service_name        = "com.amazonaws.eu-central-1.${each.key}"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = [aws_subnet.public_subnet.id]
#   private_dns_enabled = true
#   security_group_ids  = [aws_security_group.glue_sg.id]
#
#   tags = {
#     Name = "${var.repo_name}-${each.key}-vpc-endpoint"
#   }
# }
