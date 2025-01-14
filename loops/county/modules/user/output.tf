output "user_arn" {
  description = "Created IAM user ARN"
  value = aws_iam_user.example.arn
}