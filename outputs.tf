# Outputs for RDS Instance and Secrets Manager
output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance."
  value       = aws_db_instance.postgres_db.endpoint
}
output "db_instance_port" {
  description = "The port for the RDS instance."
  value       = aws_db_instance.postgres_db.port
}
output "db_password_secret_arn" {
  description = "The ARN of the secret containing the database password."
  value       = aws_secretsmanager_secret.db_password.arn
}
output "rds_endpoint" {
  description = "O endpoint (endereço) da instância do banco de dados RDS."
  value       = aws_db_instance.postgres_db.address
}

output "db_instance_address" {
  value = aws_db_instance.postgres_db.address
}

output "db_name" {
  value = aws_db_instance.postgres_db.db_name
}

output "db_username" {
  value = aws_db_instance.postgres_db.username
}

output "db_secret_name" {
  value = aws_secretsmanager_secret.db_password.name
}