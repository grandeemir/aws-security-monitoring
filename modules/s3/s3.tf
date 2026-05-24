data "aws_caller_identity" "current" {}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "security-monitoring-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CloudTrail requires a specific bucket policy to allow it to write logs to the S3 bucket. This policy grants CloudTrail the necessary permissions to put objects in the bucket and to get the bucket ACL.
data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.bucket.arn] # Kendi resource adına göre güncelle
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    
    # GARANTİ YÖNTEM: Hem direkt altına hem de gelebilecek alt kırılımlara izin vermek için iki alternatifi de ekliyoruz
    resources = [
      "${aws_s3_bucket.bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "${aws_s3_bucket.bucket.arn}/*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = "arn:aws:lambda:us-east-1:653853166958:function:DatadogIntegration-ForwarderStack-1PKXEG-Forwarder-d4EzkPVKOl36"
    events              = ["s3:ObjectCreated:*"]
  }
}