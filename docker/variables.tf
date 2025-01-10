variable "cprefix" {
  description = "Prefix for the name of the container to make sure different dev/test environments don't clash"
  default     = "dev"
}

variable "nginx1_port" {
  description = "Port to expose on the host for the first nginx container"
  default     = 80
  
}

variable "nginx2_port" {
  description = "Port to expose on the host for the first nginx container"
  default     = 8080
  
}