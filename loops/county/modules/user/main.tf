resource "aws_iam_user" "example" {
  name = var.user_name

  tags = {
    managed-by = "terraform"
  }
}
