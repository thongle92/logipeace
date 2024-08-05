### Global variables
variable "aws_region" {
  description = "This variable is where your system place"
  default     = "ap-southeast-1"
  type        = string
}
variable "app_name" {
  description = "This variable is your application name"
  default     = "logipeace"
  type        = any
}

### ECS configuration
variable "be_image" {
  description = "This variable is your Backend's image"
  default     = "nginx:latest"
  type        = string
}

variable "fe_image" {
  description = "This variable is your Front-end's image"
  default     = "nginx:latest"
  type        = string
}

variable "fe_port" {
  description = "This variable is your port FE"
  default     = 80
  type        = number
}

variable "be_port" {
  description = "This variable is your port BE"
  default     = 8080
  type        = number
}

variable "vpc_cidr" {
  description = "This is VPC's CIDR"
  default     = "10.31.0.0/16"
  type        = string
}

variable "acm_arn" {
  description = "ARN's Amazone Cert Management"
  default     = "arn:aws:acm:ap-southeast-1:0123456789:certificate/0000000-1111-2222-3333-444444"
  type        = string
}

### Autoscaling
variable "min_cap_frontend" {
  description = "Minimum front-end ASG capacity"
  default     = 2
  type        = number
}
variable "max_cap_frontend" {
  description = "Maximum front-end ASG capacity"
  default     = 4
  type        = number
}
variable "min_cap_backend" {
  description = "Minimum back-end ASG capacity"
  default     = 2
  type        = number
}
variable "max_cap_backend" {
  description = "Maximum front-end ASG capacity"
  default     = 2
  type        = number
}

variable "cpu_limited_frontend" {
  description = "Front-end's cpu limited"
  default     = 50
  type        = number
}
variable "cpu_limited_backend" {
  description = "Back-end's cpu limited"
  default     = 50
  type        = number
}

variable "mem_limited_frontend" {
  description = "Front-end's mem limited"
  default     = 50
  type        = number
}
variable "mem_limited_backend" {
  description = "Back-end's mem limited"
  default     = 50
  type        = number
}

#RDS
variable "db_storage_size" {
  description = "DB instance storage size (GB)"
  default     = 20
  type        = number
}
variable "db_engine" {
  description = "DB instance engine"
  default     = "mysql"
  type        = string
}
variable "db_engine_version" {
  description = "DB instance engine version"
  default     = 5.7
  type        = number
}
variable "db_class" {
  description = "DB instance class"
  default     = "db.t2.micro"
  type        = string
}
variable "db_master_user" {
  description = "DB instance master user"
  default     = "admin"
  type        = string
}
variable "parameter_group_name" {
  description = "DB instance parameter group name"
  default     = "default.mysql5.7"
  type        = string
}
