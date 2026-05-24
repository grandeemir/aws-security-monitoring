output "datadog_role_arn" {
  description = "ARN of the IAM Role created for Datadog AWS Integration"
  value       = aws_iam_role.datadog_aws_integration.arn
}