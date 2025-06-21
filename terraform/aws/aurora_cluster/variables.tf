# Name prefix for Aurora resources
variable "name" {
  description = "The name of the Aurora cluster"
  type        = string
}

# Database name to create in Aurora
variable "database_name" {
  description = "The name of the database for the Aurora cluster"
  type        = string
}

# Aurora master password (passed as an object for compatibility with random_password)
variable "aurora_password" {
  description = "The password for the Aurora cluster"
  type = object({
    result = string
  })
}

# Security group IDs to associate with the Aurora cluster
variable "sg_ids" {
  description = "The security group IDs for the Aurora cluster"
  type        = list(string)
}

# Subnet group name for Aurora cluster networking
variable "db_subnet_group_name" {
  description = "The name of the DB subnet group for the Aurora cluster"
  type        = string
}

# Minimum Aurora serverless v2 capacity (in Aurora capacity units)
variable "min_capacity" {
  description = "The minimum capacity for the Aurora cluster"
  type        = number
  default     = 0.0
}

# Maximum Aurora serverless v2 capacity (in Aurora capacity units)
variable "max_capacity" {
  description = "The maximum capacity for the Aurora cluster"
  type        = number
  default     = 1.0
}

# Time (in seconds) until the Aurora cluster auto-pauses when idle
variable "seconds_until_auto_pause" {
  description = "The number of seconds until the Aurora cluster auto-pauses"
  type        = number
  default     = 300
}
