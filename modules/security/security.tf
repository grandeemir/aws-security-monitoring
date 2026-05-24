resource "aws_guardduty_detector" "example" {
  enable = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  tags = var.tags
}

# SNS TOPIC
resource "aws_sns_topic" "guardduty_alerts" {
  name = "guardduty-security-alerts-topic"
}

# SNS SUBSCRIPTION
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.guardduty_alerts.arn
  protocol  = var.protocol
  
  # email address
  endpoint  = var.endpoint
}

# EVENTBRIDGE RULE
resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name        = "guardduty-findings-rule"
  description = "Capture AWS GuardDuty findings and route to SNS"

  # just medium and high threats (Severity >= 4)
  event_pattern = jsonencode({
    "source": [
      "aws.guardduty"
    ],
    "detail-type": [
      "GuardDuty Finding"
    ],
    "detail": {
      "severity": [
        { "numeric": [">=", 4] } # 4.0 - 8.9 between medium, high severity.
      ]
    }
  })
}

# Eventbridge target
resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.guardduty_alerts.arn
}

# DATADOG CREDENTIAL: 
resource "aws_cloudwatch_event_connection" "datadog" {
  name             = "datadog-api-connection"
  description      = "Connection to Datadog API for log streaming"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "DD-API-KEY"
      # your datadog api key
      value = var.datadog_api_key
    }
  }
}

#
resource "aws_cloudwatch_event_api_destination" "datadog_logs" {
  name                             = "datadog-logs-destination"
  description                      = "Send logs directly to Datadog Intake HTTP API"
  # NOT: us5 region for my datadog account, you should change it according to your datadog region
  http_method                      = "POST"
  invocation_endpoint              = "https://http-intake.logs.us5.datadoghq.com/api/v2/logs"
  connection_arn                   = aws_cloudwatch_event_connection.datadog.arn
  # how many requests per second (AWS throttling protection)
  invocation_rate_limit_per_second = 10 
}

# EVENTBRIDGE TARGET (DATADOG): 
resource "aws_cloudwatch_event_target" "datadog" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  target_id = "SendToDatadog"
  arn       = aws_cloudwatch_event_api_destination.datadog_logs.arn
  role_arn  = aws_iam_role.eventbridge_http.arn

  http_target {
    header_parameters = {
      "Content-Type" = "application/json"
    }
    query_string_parameters = {
      "ddsource" = "amazon_web_services"
      "service"  = "guardduty"
    }
  }

  # 🚀 YENİ EKLENEN KISIM: Gelen GuardDuty verisini Datadog'un yutabileceği JSON formatına çeviriyoruz
  input_transformer {
    # GuardDuty bulgusunun ham halini <json_body> adlı değişkene ata
    input_paths = {
      json_body = "$"
    }
    # Datadog'un zorunlu kıldığı "message" tag'inin içine bu gövdeyi göm
    input_template = <<EOF
{
  "message": <json_body>,
  "ddsource": "amazon_web_services",
  "service": "guardduty",
  "ddtags": "env:dev,security:guardduty"
}
EOF
  }
}

# IAM ROLE & POLICY: 
resource "aws_iam_role" "eventbridge_http" {
  name = "eventbridge-http-destination-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_http_policy" {
  name = "eventbridge-http-policy"
  role = aws_iam_role.eventbridge_http.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "events:InvokeApiDestination"
        ]
        Effect   = "Allow"
        Resource = aws_cloudwatch_event_api_destination.datadog_logs.arn
      }
    ]
  })
}

# SNS POLICY: 
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.guardduty_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowEventBridgeToPublish"
        Effect   = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.guardduty_alerts.arn
      }
    ]
  })
}
