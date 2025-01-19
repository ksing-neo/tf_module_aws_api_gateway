provider "aws" {

  region = var.region

    default_tags {
      tags = {
        Application = var.function_name
      }
    }
}