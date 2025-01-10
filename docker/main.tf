resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "docker_container" "nginx1" {
  image        = docker_image.nginx.image_id
  name         = "${var.cprefix}-nginx1"
  network_mode = "bridge"
  ports {
    internal = 80
    external = var.nginx1_port
  }
}

resource "docker_container" "nginx2" {
  image        = docker_image.nginx.image_id
  name         = "${var.cprefix}-nginx2"
  network_mode = "bridge"
  ports {
    internal = 80
    external = var.nginx2_port
  }
}

