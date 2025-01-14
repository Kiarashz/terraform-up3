# once switched from count to for_each
# the following does not work anymore
# output "users" {
#   value = module.users[*].user_arn
# }


output "users" {
  value = values(module.users)
}
