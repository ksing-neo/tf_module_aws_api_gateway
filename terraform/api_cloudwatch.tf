resource "aws_cloudwatch_log_group" "api" {
    name = "/restapi/${var.function_name}"

    tags = {
        Application = "${var.function_name}"
    }
}