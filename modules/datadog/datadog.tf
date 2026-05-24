data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Datadog'un bu rolü üstlenebilmesi (AssumeRole) için güven ilişkisi (Trust Policy)
data "aws_iam_policy_document" "datadog_aws_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.datadog_aws_account_id}:root"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.datadog_external_id]
    }
  }
}

# IAM Rolünün oluşturulması
resource "aws_iam_role" "datadog_aws_integration" {
  name               = "DatadogAWSIntegrationRole"
  assume_role_policy = data.aws_iam_policy_document.datadog_aws_trust_policy.json
}

# Datadog'un CloudTrail ve temel servis metriklerini okuyabilmesi için gerekli izinler
# (Core Security yetkilerini içerir)
resource "aws_iam_policy" "datadog_aws_core_policy" {
  name        = "DatadogAWSCoreIntegrationPolicy"
  description = "Minimum permissions for Datadog AWS integration to monitor CloudTrail and basic service metrics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudtrail:LookupEvents",
          "cloudtrail:DescribeTrails",
          "cloudtrail:GetTrailStatus",
          "guardduty:ListFindings",
          "guardduty:GetFindings",
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "support:*",
          "tag:GetResources",
          "tag:GetTagKeys"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Politikayı Role bağlıyoruz
resource "aws_iam_role_policy_attachment" "datadog_aws_attach" {
  role       = aws_iam_role.datadog_aws_integration.name
  policy_arn = aws_iam_policy.datadog_aws_core_policy.arn
}


# ==========================================
# DATADOG AWS INTEGRATION AUTOMATION
# ==========================================

# Datadog panelindeki AWS entegrasyon sayfasını otomatik doldurur ve eşler
resource "datadog_integration_aws" "core_integration" {
  account_id = data.aws_caller_identity.current.account_id
  role_name  = aws_iam_role.datadog_aws_integration.name
}

# CloudTrail loglarının Datadog tarafından otomatik toplanmasını aktif eder
resource "datadog_integration_aws_lambda_arn" "main_collector" {
  account_id = data.aws_caller_identity.current.account_id
  lambda_arn = "arn:aws:lambda:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:function:DatadogIntegration-ForwarderStack-1PKXEGP4KXN5I"
  
  depends_on = [datadog_integration_aws.core_integration]
}