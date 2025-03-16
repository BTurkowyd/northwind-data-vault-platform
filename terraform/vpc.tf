# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dbt-data-vault-vpc"
  }
}

resource "aws_vpc_endpoint" "s3_vpc_endpoint" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.eu-central-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_route_table.private_rt.id]  # Attach to private route table

  tags = {
    Name = "s3-vpc-endpoint"
  }
}

# Create Subnets (Aurora requires at least 2, both are private)
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "dbt-data-vault-subnet-1"
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
    Name = "dbt-data-vault-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "dbt-data-vault-igw"
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