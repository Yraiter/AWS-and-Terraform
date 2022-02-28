# Variables #
variable "region" {
  default = "us-east-1"
  type    = string
}
variable "availability_zone" {
  type = list(string)
}
variable "instance_type" {
  description = "The type of the nginx EC2, for example - t2.medium"
  type        = string
  default     = "t2.micro"
}
variable "instance_count" {}
variable "aws_creds_file" {}
variable "aws_profile" {}
#variable "key_name" {
#    default     = "OpsSchool"
#    description = "The key name of the Key Pair to use for the instance"
#    type = string
#}
variable "vpc_cidr" {}
variable "private_cidr" {
  type = list(string)
}
variable "public_cidr" {
  type = list(string)
}

variable "ec2_device_names" {
  type = list(string)
  default = [
    "/dev/sdd",
    "/dev/sde",
    "/dev/sdf",
  ]
}