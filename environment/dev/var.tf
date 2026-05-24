variable "protocol" {
  type    = string
  default = "email" 
}

variable "endpoint" {
  sensitive = true
  # default value should be set in .env file or through environment variables for security reasons
}

variable "datadog_api_key" {
  sensitive = true
  # default value should be set in .env file or through environment variables for security reasons
}

variable "datadog_external_id" {
  sensitive = true
    # default value should be set in .env file or through environment variables for security reasons
}
