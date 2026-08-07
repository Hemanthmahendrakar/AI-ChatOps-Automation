variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}


variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}


variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
}


variable "availability_zone" {
  description = "AWS availability zone"
  type        = string
}

variable "my_ip" {
  description = "Your public IP address for SSH access"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "EC2 AMI ID"
  type        = string
}
