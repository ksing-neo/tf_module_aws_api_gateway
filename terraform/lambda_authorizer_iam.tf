resource "aws_iam_role" "iam_for_lambda_authorizer" {
    name = "${var.resource_name}_authorizer"
    assume_role_policy = data.aws_iam_policy_document.assume_role_authorizer.json

    tags = {
        Application = "${var.application}"
        Function = "${var.function_name}"
    }
}

data "aws_iam_policy_document" "assume_role_authorizer" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "role_policy_authorizer" {
  name = "${var.resource_name}_authorizer"
  role = aws_iam_role.iam_for_lambda_authorizer.id

  policy = jsonencode (
    {
      Version = "2012-10-17"
      Statement =[
        {
          "Action": "logs:CreateLogGroup",
          "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
          "Effect": "Allow"
        },
        {
          "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.resource_name}_authorizer:*",
          "Effect": "Allow"
        },
        {
          "Action": [
            "sns:Publish"
          ],
          "Resource": aws_sns_topic.sns.arn,
          "Effect": "Allow"
        },
      ]
    }
  )
}