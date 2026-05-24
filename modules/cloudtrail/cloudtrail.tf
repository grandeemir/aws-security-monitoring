resource "aws_cloudtrail" "security_trail" {
  name                          = var.name
  s3_bucket_name                = var.s3_bucket_name
  s3_key_prefix                 = "cloudtrail-logs"
  include_global_service_events = true
  is_multi_region_trail         = true
  
  # it is recommended to enable log file validation for security purposes, as it allows you to verify the integrity of the log files and ensure that they have not been tampered with.
  enable_log_file_validation    = true 

  tags = var.tags
}