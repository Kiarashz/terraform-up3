provider "aws" {
  region = "ap-southeast-2"
}

module "users" {
  source = "./modules/user"

  count = length(var.user_names)
  user_name = "${var.user_names[count.index]}"
}