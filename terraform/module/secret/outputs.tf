output "apisecret" {
  value = aws_secretsmanager_secret_version.cr.secret_string
}
