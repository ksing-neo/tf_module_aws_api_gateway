output "sns_arn" {
    value = aws_sns_topic.sns.arn
}

output "api_URL" {
    value = aws_apigatewayv2_api.api.api_endpoint
}
