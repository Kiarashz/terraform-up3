data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"] # AMIs owned by Amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-arm64-gp2"] # Filter for Amazon Linux 2 AMIs
  }

  filter {
    name   = "architecture"
    values = ["arm64"] # Specify the architecture (e.g., arm64)
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "subnet-id"
    values = ["subnet-387af94f", "subnet-e53a5f80"]
  }
}
