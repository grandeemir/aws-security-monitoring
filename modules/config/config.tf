# AWS Config için IAM Rolü
resource "aws_iam_role" "config_role" {
  name = "aws-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "config.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "config_logs" {
  bucket = "${var.config_logs}-${random_id.bucket_suffix.hex}"

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  rule {
    id     = "ExpireOldVersions"
    status = "Enabled"
  }
}

# just allow config to write logs to this bucket, no public access allowed
resource "aws_s3_bucket_policy" "config_allow_policy" {
  bucket = aws_s3_bucket.config_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSConfigBucketPermissionsCheck"
        Effect    = "Allow"
        Principal = { Service = "config.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.config_logs.arn
      },
      {
        Sid       = "AWSConfigBucketDelivery"
        Effect    = "Allow"
        Principal = { Service = "config.amazonaws.com" }
        Action    = "s3:PutObject"
        # Sadece bu bucket'ın altındaki AWSLogs klasörüne yazma izni veriyoruz
        Resource  = "${aws_s3_bucket.config_logs.arn}/AWSLogs/*"
        Condition = {
          StringEquals = {
            # Güvenlik Önlemi: Dosyayı yazan kişinin bucket sahibine tam kontrol vermesini zorunlu kılıyoruz
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# Config Recorder (Değişiklikleri kaydeder)
resource "aws_config_configuration_recorder" "main" {
  name     = "aws-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                = true
    include_global_resource_types = true
  }
  
  depends_on = [aws_s3_bucket_policy.config_allow_policy]
}

# Config'in logları yazacağı S3 Kovası (Diyagramındaki S3 ile aynı mantıkta, ayrı bir bucket da olabilir)
resource "aws_config_delivery_channel" "main" {
  name           = "aws-config-delivery-channel"
  s3_bucket_name = var.config_logs 
  depends_on     = [aws_config_configuration_recorder.main]
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.main]
}

# ÖRNEK CIS KURALI: Root hesabında MFA aktif mi?
resource "aws_config_config_rule" "iam_root_mfa" {
  name        = "iam-root-access-key-check"
  description = "Checks whether the root account has an access key (CIS Standard)"
  
  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }
  depends_on = [aws_config_configuration_recorder_status.main]
}