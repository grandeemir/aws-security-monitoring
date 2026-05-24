data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "athena_results" {
  bucket        = "athena-query-results-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "athena_results_bpa" {
  bucket                  = aws_s3_bucket.athena_results.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ==========================================
# ATHENA WORKGROUP YAPILANDIRMASI
# ==========================================
resource "aws_athena_workgroup" "security_wg" {
  name        = "security-analysis-workgroup"
  description = "  Workgroup for security monitoring queries"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/"
    }
  }
}

# ==========================================
# ATHENA DATABASE CREATION
# ==========================================
resource "aws_athena_database" "security_db" {
  name   = "security_monitoring_db"
  bucket = aws_s3_bucket.athena_results.id # Store Metadata in the same bucket as query results
}