# Security Group for Aurora
resource "aws_security_group" "aurora_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # Allow access from within the VPC
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.glue_sg.id] # Allow access from Glue security group
  }

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
# Aurora Subnet Group (Required for Multi-AZ)
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "${var.repo_name}-aurora-subnet-group"
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  tags = {
    Name = "${var.repo_name}-aurora-subnet-group"
  }
}

# Generate a random password for the Aurora DB
resource "random_password" "aurora_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}


module "northwind" {
  source               = "./aurora_cluster"
  name                 = "northwind"
  aurora_password      = random_password.aurora_password
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
  sg_ids               = [aws_security_group.aurora_sg.id]
  database_name        = "northwind_db"
}
