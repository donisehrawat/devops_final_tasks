terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-12345"
    key            = "vpc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
