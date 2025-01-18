variable "application" {
    description = "Application Name"
    type = string
}

variable "function_name" {
    description = "Name of the Function"
    type = string
}

variable "resource_name" {
    description = "Name of the resources"
    type = string
}

variable "domain_name" {
    description = "Name of the domain"
    type = string
}

variable "region" {
    description = "Region to deploy the code"
    type = string
}

variable "lambda_invoke_arn" {
    description = "Invoke ARN of the Lambda Function"
    type = string
}

variable "sns_notification" {
    description = "Email Address to receive SNS Notification"
    type = string
    default = "jersey_pasture.07@icloud.com"
}

