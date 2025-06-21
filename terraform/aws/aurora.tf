# Security Group for Aurora PostgreSQL cluster
resource "aws_security_group" "aurora_sg" {
  vpc_id = aws_vpc.main.id

  # Allow PostgreSQL access from within the VPC
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # Internal VPC access
  }

  # Allow PostgreSQL access from the Glue security group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.glue_sg.id] # Glue ETL access
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.repo_name}-aurora-sg"
  }
}

# Aurora Subnet Group (required for Multi-AZ deployments)
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  tags = {
    Name = "${var.repo_name}-aurora-subnet-group"
  }
}

# Generate a random password for the Aurora DB master user
resource "random_password" "aurora_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Aurora cluster module for Northwind database
module "northwind" {
  source               = "./aurora_cluster"
  name                 = "northwind"
  aurora_password      = random_password.aurora_password
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
  sg_ids               = [aws_security_group.aurora_sg.id]
  database_name        = "northwind_db"
}
