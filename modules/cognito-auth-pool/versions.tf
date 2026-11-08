# names required TF version
terraform {
  required_version = ">= 1.16"
  required_providers {
    aws = {
      configuration_aliases = [aws.cognito, aws.dns]
      source                = "hashicorp/aws"
      version               = ">= 6.72"
    }
  }
}
