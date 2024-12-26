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
  tags = {
    Name = "ingress_https_to_elb"
  }  
}

resource "aws_vpc_security_group_egress_rule" "allow_to_webservers" {
  security_group_id = aws_security_group.load_balancer.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 443
  ip_protocol       = "tcp"
  tags = {
    Name = "egress_https_to_webservers"
  }
}

resource "aws_alb" "webserverslb" {
  name               = "webservers-lb"
  load_balancer_type = "application"
  subnets            = [aws_default_subnet.public_az1.id, aws_default_subnet.public_az2.id]
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

###########################################
#           Provision ASG                 #
###########################################

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
  # set source to upstream security group
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

# let webserver talk to the internet (requires NAT gateway)
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
    associate_public_ip_address = false
    security_groups             = [aws_security_group.my_webserver.id]
  }

  user_data = filebase64("userdata.sh")
}

resource "aws_autoscaling_group" "webservers" {
  name = "webservers-asg"
  launch_template {
    id = aws_launch_template.webserver.id
  }
  vpc_zone_identifier = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]
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

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "NAT Gateway EIP"
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_default_subnet.public_az1.id
  
}

# create route table for private subnets to use NAT gateway
resource "aws_route_table" "private_rt" {
  vpc_id = data.aws_vpc.default.id
  tags = {
    Name = "route-table-4-private-subnets"
  }  

}

resource "aws_route" "private_to_nat" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
}

resource "aws_route" "private_local" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "172.31.0.0/16"
  gateway_id = "local"
}

resource "aws_route_table_association" "private_az1" {
  subnet_id      = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_az2" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.private_rt.id
}