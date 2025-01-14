variable "allowed_ssh_source_ip" {
  default     = "123.123.123.123/32"
  description = "replace this with your IP4 address to restrict SSH from your IP only"
}

variable "custom_tags" {
  description = "common tags to set on resources"
  type        = map(string)
  default = {
    "managed-by" = "terraform"
    "team"       = "devops"
  }
}
