# Security Hub Servisinin Aktif Edilmesi
resource "aws_securityhub_account" "main" {}

# CIS AWS Foundations Benchmark v1.4.0 Standardına Abone Olunması
resource "aws_securityhub_standards_subscription" "cis_benchmark" {
  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${var.region}::standards/cis-aws-foundations-benchmark/v1.4.0"
}