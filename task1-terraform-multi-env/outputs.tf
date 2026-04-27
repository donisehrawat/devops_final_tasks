output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns" {
  value = module.ec2.alb_dns
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "s3_bucket" {
  value = aws_s3_bucket.app_bucket.bucket
}
