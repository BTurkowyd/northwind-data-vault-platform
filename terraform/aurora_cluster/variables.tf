variable "name" {
    description = "The name of the Aurora cluster"
    type        = string
}

variable "database_name" {
    description = "The name of the database for the Aurora cluster"
    type        = string
}

variable "aurora_password" {
    description = "The password for the Aurora cluster"
    type        = object({
        result = string
    })
}

variable "sg_ids" {
    description = "The security group IDs for the Aurora cluster"
    type        = list(string)
}

variable "db_subnet_group_name" {
    description = "The name of the DB subnet group for the Aurora cluster"
    type        = string
}

variable "min_capacity" {
    description = "The minimum capacity for the Aurora cluster"
    type        = number
    default     = 0.0
}

variable "max_capacity" {
    description = "The maximum capacity for the Aurora cluster"
    type        = number
    default     = 1.0
}

variable "seconds_until_auto_pause" {
    description = "The number of seconds until the Aurora cluster auto-pauses"
    type        = number
    default     = 300
}