output "alb_dns" {
value = module.ec2.alb_dns
}
output "rds_endpoint" {
value = module.rds.rds_endpoint
}
