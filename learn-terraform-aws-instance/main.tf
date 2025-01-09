terraform {
  cloud {
    organization = "kiatel"
    workspaces {
      name = "learn-terraform-aws"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-2"
}

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

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t4g.nano"
  key_name = "cert-practice"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
