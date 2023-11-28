
##################################################################
# Build secrets entry
##################################################################
resource "random_id" "api" {
  byte_length = 32
}

resource "aws_secretsmanager_secret" "cr" {
  name = "cr-secret-${lower(var.name)}-${var.env}"
  recovery_window_in_days = 0
  replica {
      region = var.backup_region
  }
}

resource "aws_secretsmanager_secret_version" "cr" {
  secret_id     = aws_secretsmanager_secret.cr.id
  secret_string = var.set_secret != "" ? var.set_secret : random_id.api.hex
}
