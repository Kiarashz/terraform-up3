provider "aws" {
  region = "ap-southeast-2"
}

module "users" {
  source = "./modules/user"

  # this use of count can't handle list updates correctly 
  # so better to use for_each
  # count = length(var.user_names)
  # user_name = "${var.user_names[count.index]}"
  for_each = toset(var.user_names)
  user_name = "${each.value}"
}