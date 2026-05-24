# modules/datadog/providers.tf

terraform {
  required_providers {
    # AWS zaten varsayılan olarak tanınır ama Datadog'un kaynağını burada da belirtmeliyiz
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
  }
}