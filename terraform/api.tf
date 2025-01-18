resource "aws_apigatewayv2_api" "api" {
    name = var.resource_name
    protocol_type = "HTTP"
    description = "API Gateway V2 for ${var.resource_name}"

    tags = {
        Application = "${var.application}"
        Function = "${var.function_name}"
    }
}

resource "aws_apigatewayv2_authorizer" "api_authorizer" {
    name = var.resource_name
    api_id = aws_apigatewayv2_api.api.id
    authorizer_uri = aws_lambda_function.lambda_authorizer.invoke_arn
    authorizer_type = "REQUEST"
    identity_sources = ["$request.header.origin"]
    authorizer_payload_format_version = "1.0"

    # Disabling the authorization cache
    # authorizer_result_ttl_in_seconds = 0
}

resource "aws_apigatewayv2_stage" "api" {
    api_id = aws_apigatewayv2_api.api.id
    name = "prod"
    deployment_id = aws_apigatewayv2_deployment.api.id
    access_log_settings {
      destination_arn = aws_cloudwatch_log_group.api.arn
      format = "{\"requestId\":\"$context.requestId\",\"routeKey\":\"$context.routeKey\",\"httpMethod\",\"$context.httpMethod\",\"integrationErrorMessage\":\"$context.integrationErrorMessage \"}"
    }
}

resource "aws_apigatewayv2_deployment" "api" {
    api_id = aws_apigatewayv2_api.api.id
    
    triggers = {
        redeployment = sha1(join(",",tolist([
            jsonencode(aws_apigatewayv2_integration.api_integration),
            jsonencode(aws_apigatewayv2_route.api_route_POST),
            jsonencode(aws_apigatewayv2_route.api_route_OPTIONS),
        ])))
    }

    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_api_gateway_account" "api" {
    cloudwatch_role_arn = aws_iam_role.iam_for_api.arn
}

resource "aws_apigatewayv2_integration" "api_integration" {
    api_id = aws_apigatewayv2_api.api.id
    integration_type = "AWS_PROXY"
    integration_method = "POST"
    integration_uri = var.lambda_invoke_arn
}

resource "aws_apigatewayv2_route" "api_route_POST" {
    api_id = aws_apigatewayv2_api.api.id
    route_key = "POST /${var.function_name}"
    target = "integrations/${aws_apigatewayv2_integration.api_integration.id}"

    authorization_type = "CUSTOM"
    authorizer_id = aws_apigatewayv2_authorizer.api_authorizer.id
}

resource "aws_apigatewayv2_route" "api_route_OPTIONS" {
    api_id = aws_apigatewayv2_api.api.id
    route_key = "OPTIONS /${var.function_name}"
    target = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
}