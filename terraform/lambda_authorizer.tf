data "archive_file" "lambda_authorizer" {
    type = "zip"
    source_file = "${path.module}/../lambda_authorizer/lambda.py"
    output_path = "${path.module}/../lambda_authorizer/lambda.zip"
}

resource "aws_lambda_function" "lambda_authorizer" {
    function_name = "${var.resource_name}_authorizer"
    handler = "lambda.main"
    runtime = "python3.11"
    filename = "${path.module}/../lambda_authorizer/lambda.zip"
    role = aws_iam_role.iam_for_lambda_authorizer.arn
    

    source_code_hash = data.archive_file.lambda_authorizer.output_base64sha256
    timeout = 300 # 1 minute

    environment {
      variables = {
        origin = "https://${var.domain_name}"
        application = var.resource_name
        sns_topic_arn = aws_sns_topic.sns.arn
        api_arn = "${aws_apigatewayv2_api.api.execution_arn}/prod/POST/${var.function_name}"
      }
    }

    tags = {
        Application = "${var.application}"
        Function = "${var.function_name}"
    }
} 

resource "aws_lambda_permission" "apigw_lambda_authorizer" {
    statement_id = "AllowAPIGatewayInvoke"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_authorizer.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}