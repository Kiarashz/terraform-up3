resource "docker_image" "nginx" {
 name = "nginx:latest"
  
}

resource "docker_container" "nginx1" {
 image = docker_image.nginx.image_id
 name  = "nginx1"
 network_mode = "bridge"
 ports {
   internal = 80
   external = 80
 }
}

resource "docker_container" "nginx2" {
 image = docker_image.nginx.image_id
 name  = "nginx2"
 network_mode = "bridge"
 ports {
   internal = 80
   external = 8080
 }
}

