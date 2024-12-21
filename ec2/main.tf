resource "aws_security_group" "my_webserver" {
  name   = "my_webserver"
  vpc_id = data.aws_vpc.default.id
  tags = {
    Name     = "my_webserver"
    FUNCTION = "allow http from vpc"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_from_vpc_ipv4" {
  security_group_id = aws_security_group.my_webserver.id
  referenced_security_group_id = aws_security_group.load_balancer.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  tags = {
    Name = "allow_http_from_vpc_ipv4"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_private" {
  security_group_id = aws_security_group.my_webserver.id
  cidr_ipv4         = var.allowed_ssh_source_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  tags = {
    Name = "allow_ssh_from_home_ipv4"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_out" {
  security_group_id = aws_security_group.my_webserver.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 443
  ip_protocol       = "tcp"
  tags = {
    Name = "allow_https_to_everywhere"
  }
}


resource "aws_launch_template" "webserver" {
  name          = "webserver"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t4g.nano"

  key_name = "cert-practice"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.my_webserver.id]
  }

  user_data = filebase64("userdata.sh")
}

resource "aws_autoscaling_group" "webservers" {
  name = "webservers-asg"
  launch_template {
    id = aws_launch_template.webserver.id
  }
  vpc_zone_identifier = data.aws_subnets.default.ids
  min_size            = 2
  max_size            = 3

  target_group_arns = [aws_lb_target_group.webservers.arn]
  health_check_type = "ELB"  # or EC2

  tag {
    key                 = "Name"
    value               = "webserver-asg"
    propagate_at_launch = true
  }
}

###########################################
#           Provision ALB                 #
###########################################
resource "aws_security_group" "load_balancer" {
  name   = "load_balancer"
  vpc_id = data.aws_vpc.default.id
  tags = {
    Name     = "load_balancer"
    FUNCTION = "allow http from the internet"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_load_balancer_ipv4" {
  security_group_id = aws_security_group.load_balancer.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_to_webservers" {
  security_group_id = aws_security_group.load_balancer.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 443
  ip_protocol       = "tcp"
  tags = {
    Name = "allow_https_to_webservers"
  }
}

resource "aws_alb" "webserverslb" {
  name               = "webservers-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.load_balancer.id]
  tags = {
    Function = "webservers load balancer"
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_alb.webserverslb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }

}

resource "aws_lb_target_group" "webservers" {
  name     = "httpwebservers"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200,202,403,404"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "webserver" {
  listener_arn = aws_lb_listener.lb_listener.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webservers.arn
  }
}
