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
}

module "config" {
  source = "../../modules/config"
  config_logs = "config-logs-bucket"
  tags       = local.common_tags
}

module "security_hub" {
  source = "../../modules/security_hub"
  region = "us-east-1"
  # NOT: Eğer projen us-east-1 (N. Virginia) dışında bir bölgedeyse (region), 
  # yukarıdaki ARN içindeki bölge ismini kendi kullandığın bölgeyle değiştirmelisin.
}