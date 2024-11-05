resource "aws_launch_configuration" "webserver" {
  name          = "webserver"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install httpd
    EOF
}

resource "aws_autoscaling_group" "webservers" {
  name = "webservers-asg"
  launch_configuration = aws_launch_configuration.webserver
  min_size = 1
  max_size = 2
  lifecycle {
    create_before_destroy = true
  }
}
