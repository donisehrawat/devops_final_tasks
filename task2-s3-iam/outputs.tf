output "bucket_names" {
value = { for k, v in aws_s3_bucket.env_buckets : k => v.bucket }
}
output "iam_users" {
  value = [for u in aws_iam_user.users : u.name]
}
