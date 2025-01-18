resource "aws_cloudwatch_log_group" "api" {
    name = "/restapi/${var.resource_name}"

    tags = {
        Application = "${var.application}"
        Function = "${var.function_name}"
    }
}