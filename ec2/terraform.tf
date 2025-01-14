# this is sample exercise so not locking to any terraform/provider version
provider "aws" {
  region = "ap-southeast-2" # sydney

  # Tags to apply to all AWS resources by default
  default_tags {
    tags = {
      Owner     = "team-devops"
      ManagedBy = "Terraform"
    }
  }  
}
