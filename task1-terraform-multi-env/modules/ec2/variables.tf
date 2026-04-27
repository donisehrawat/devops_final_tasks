variable "env" {}

variable "vpc_id" {}

variable "public_subnet1_id" {}

variable "public_subnet2_id" {}

variable "private_subnet1_id" {}

variable "private_subnet2_id" {}

variable "ami_id" {}

variable "instance_type" {}

variable "min_size" {
  default = 2
}

variable "max_size" {
  default = 5
}
