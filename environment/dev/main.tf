module "s3" {
  source = "../../modules/s3"
  tags   = local.common_tags
}

module "cloudtrail" {
  source         = "../../modules/cloudtrail"
  name           = "security-trail"
  s3_bucket_name = module.s3.s3_bucket.bucket
  s3_bucket_id   = module.s3.bucket_policy_id
  tags           = local.common_tags
  depends_on     = [module.s3]
}

module "athena" {
  source                = "../../modules/athena"
  cloudtrail_bucket_id  = module.s3.bucket_id
  cloudtrail_bucket_arn = module.s3.bucket_arn

  depends_on = [module.cloudtrail]
}

module "datadog" {
  source = "../../modules/datadog"
  datadog_aws_account_id = "464622532012" # offical Datadog AWS Account ID
  datadog_external_id    = var.datadog_external_id # your generated external id for datadog integration

  depends_on = [module.athena]
}

module "guardduty" {
  source = "../../modules/security"
  tags   = local.common_tags
  protocol = var.protocol # e.g. "email"
  endpoint = var.endpoint # your email address for receiving alerts
  datadog_api_key = var.datadog_api_key # your datadog api key for log streaming
  datadog_forwarder_arn = "arn:aws:lambda:us-east-1:653853166958:function:DatadogIntegration-ForwarderStack-1PKXEG-Forwarder-d4EzkPVKOl36" # your datadog forwarder arn for log streaming
  securityhub_to_eventbridge_name = "securityhub-to-eventbridge" # name for security hub to eventbridge integration
}

module "config" {
  source = "../../modules/config"
  config_logs = "config-logs-bucket"
  tags       = local.common_tags
}

module "security_hub" {
  source = "../../modules/security_hub"
}