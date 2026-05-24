output "s3_bucket" {
  value = aws_s3_bucket.bucket
}

output "bucket_policy_id" {
  value = aws_s3_bucket_policy.bucket_policy.id
}

output "bucket_id" {
  value = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}