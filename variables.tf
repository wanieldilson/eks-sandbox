variable "environment" {
  type = string
}

variable "aws_region" {
  description = "The AWS region to create things in"
  default     = "eu-west-2"
}
variable "aws_access_key" {
  description = "aws access key for YACE"
  type        = string
}
variable "aws_secret_key" {
  description = "aws secret key for YACE"
  type        = string
}

variable "owner-email" {
  type    = string
}

variable "cluster-name" {
  type    = string
}

variable "myip" {
  type = string
  
}