terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      version = ">=5.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket         = "my-terraform-state-01419a9d"
    key            = "awsSecurityMonitoring/terraform.tfstate"
    dynamodb_table = "terraform-state-locks"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "datadog" {
  api_url = "https://api.us5.datadoghq.com" # Hesabın EU tabanlıysa .eu, US tabanlıysa .com yapmalısın
}