module "vpc" {
source = "./modules/vpc"
vpc_cidr = var.vpc_cidr
public_subnet1_cidr = var.public_subnet1_cidr
public_subnet2_cidr = var.public_subnet2_cidr
  private_subnet1_cidr = var.private_subnet1_cidr
  private_subnet2_cidr = var.private_subnet2_cidr
    az1 = var.az1
    az2 = var.az2
  env = var.env
}

module "ec2" {
  source = "./modules/ec2"
    env = var.env
  vpc_id = module.vpc.vpc_id
  public_subnet1_id = module.vpc.public_subnet1_id
  public_subnet2_id = module.vpc.public_subnet2_id
    private_subnet1_id = module.vpc.private_subnet1_id
    private_subnet2_id = module.vpc.private_subnet2_id
  ami_id = var.ami_id
  instance_type = var.instance_type
}
module "rds" {
source = "./modules/rds"
env = var.env
vpc_id = module.vpc.vpc_id
private_subnet1_id = module.vpc.private_subnet1_id
private_subnet2_id = module.vpc.private_subnet2_id
ec2_sg_id = module.ec2.ec2_sg_id
db_instance_class = var.db_instance_class
db_name = var.db_name
db_username = var.db_username
db_password = var.db_password
}


resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.env}-myapp-bucket"
}
resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
bucket = aws_s3_bucket.app_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
