output "rds_endpoint" { value = aws_db_instance.mysql.endpoint }
output "db_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.mysql.id
}
