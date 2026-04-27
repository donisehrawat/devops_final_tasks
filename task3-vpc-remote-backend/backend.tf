terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-12345"
    key            = "vpc/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
  }
}
