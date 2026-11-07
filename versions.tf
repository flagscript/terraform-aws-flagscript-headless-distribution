# names required TF version
terraform {
  required_version = ">= 1.16"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 6.72"
      configuration_aliases = [aws.dist, aws.dns]
    }
  }
}
