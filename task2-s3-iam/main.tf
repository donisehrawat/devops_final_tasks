locals {
  environments = {
    dev = {
      bucket_suffix = "dev-storage"
      versioning    = true
      users         = ["saksham", "akshat"]
    }
    staging = {
      bucket_suffix = "staging-storage"
      versioning    = false
      users         = ["udhav"]
    }
    prod = {
      bucket_suffix = "prod-storage"
      versioning    = true
      users         = ["shimon", "saksham"]
    }
  }

  all_users = distinct(flatten([for env, config in local.environments : config.users]))
}

resource "aws_s3_bucket" "env_buckets" {
  for_each = local.environments
  bucket   = "myapp-${each.key}-${each.value.bucket_suffix}"
}

resource "aws_s3_bucket_versioning" "env_versioning" {
  for_each = { for k, v in local.environments : k => v if v.versioning }
  bucket   = aws_s3_bucket.env_buckets[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "env_lifecycle" {
  for_each = local.environments
  bucket   = aws_s3_bucket.env_buckets[each.key].id

  dynamic "rule" {
    for_each = each.key == "prod" ? [1] : []
    content {
      id     = "move-to-glacier"
      status = "Enabled"
      transition {
        days          = 90
        storage_class = "GLACIER"
      }
    }
  }

  rule {
    id     = "delete-old"
    status = "Enabled"
    expiration {
      days = 30
    }
  }
}

resource "aws_iam_user" "users" {
  for_each = toset(local.all_users)
  name     = each.value
}

resource "aws_iam_policy" "env_policies" {
  for_each = local.environments
  name     = "${each.key}-s3-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.env_buckets[each.key].arn,
          "${aws_s3_bucket.env_buckets[each.key].arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "user_attachments" {
  for_each = {
    for pair in flatten([
      for env, config in local.environments : [
        for user in config.users : {
          key  = "${env}-${user}"
          user = user
          env  = env
        }
      ]
    ]) : pair.key => pair
  }

  user       = aws_iam_user.users[each.value.user].name
  policy_arn = aws_iam_policy.env_policies[each.value.env].arn
}
