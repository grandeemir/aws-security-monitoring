data "aws_caller_identity" "current" {}

# Security Hub Servisinin Aktif Edilmesi
resource "aws_securityhub_account" "main" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_securityhub_account.main]

  create_duration = "30s"
}

# CIS AWS Foundations Benchmark v1.4.0 Standardına Abone Olunması
resource "aws_securityhub_standards_subscription" "cis_benchmark" {
  depends_on    = [time_sleep.wait_30_seconds] # Security Hub'un tam olarak aktifleşmesi için kısa bir bekleme süresi ekliyoruz
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}