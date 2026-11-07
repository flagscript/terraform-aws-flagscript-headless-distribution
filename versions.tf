# names required TF version
terraform {
  required_version = "~> 1.15"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 6.0"
      configuration_aliases = [aws.dist, aws.dns]
    }
  }
}
