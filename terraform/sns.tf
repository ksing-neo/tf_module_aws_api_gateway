resource "aws_sns_topic" "sns" {
    name = var.function_name
    kms_master_key_id = "alias/aws/sns"

    tags = {
        Application = "${var.function_name}"
    }
}

resource "aws_sns_topic_policy" "sns_policy" {
    arn = aws_sns_topic.sns.arn
    policy = data.aws_iam_policy_document.sns_topic_policy.json

}

resource "aws_sns_topic_subscription" "sns_subscription_email" {
    topic_arn = aws_sns_topic.sns.arn
    protocol = "email"
    endpoint = var.sns_notification
}

data "aws_iam_policy_document" "sns_topic_policy" {
    statement {
        actions = [
            "SNS:Publish"
        ]

        effect = "Allow"

        principals {
          type = "Service"
          identifiers = ["lambda.amazonaws.com"]
        }

        resources = [ aws_sns_topic.sns.arn,]

    }
}