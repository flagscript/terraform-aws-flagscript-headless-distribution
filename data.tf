# AWS lookups
data "aws_partition" "distribution" {
  provider = aws.dist
}

data "aws_caller_identity" "distribution" {
  provider = aws.dist
}
