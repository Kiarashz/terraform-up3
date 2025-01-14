output "users" {
  value = module.users[*].user_arn
}