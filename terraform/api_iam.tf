resource "aws_iam_role" "iam_for_api" {
    name = "restapi_${var.function_name}"
    assume_role_policy = data.aws_iam_policy_document.iam_for_api_assume.json

    tags = {
        Application = "${var.function_name}"
    }
}

data "aws_iam_policy_document" "iam_for_api_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "iam_for_api_role" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "iam_for_api" {
  name   = "restapi_${var.function_name}"
  role   = aws_iam_role.iam_for_api.id
  policy = data.aws_iam_policy_document.iam_for_api_role.json
}