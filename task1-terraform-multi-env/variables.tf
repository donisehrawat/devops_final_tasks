variable "region" {
  default = "ap-south-1"
}

variable "env" {}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet1_cidr" {
  default = "10.0.1.0/24"
}

variable "public_subnet2_cidr" {
  default = "10.0.2.0/24"
}

variable "private_subnet1_cidr" {
  default = "10.0.3.0/24"
}

variable "private_subnet2_cidr" {
  default = "10.0.4.0/24"
}

variable "az1" {
  default = "ap-south-1a"
}

variable "az2" {
  default = "ap-south-1b"
}

variable "ami_id" {
  default = "ami-0f58b397bc5c1f2e8"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "db_name" {}

variable "db_username" {}

variable "db_password" {}
