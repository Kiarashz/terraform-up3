output "selected-azs" {
  value = data.aws_subnets.default.ids
#   value = slice(data.aws_subnets.default.ids, 0,2)
}
output "webserver_lb_url" {
  value = aws_alb.webserverslb.dns_name
}