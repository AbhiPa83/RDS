output "db_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.mysql.identifier # Direct resource reference
}

output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.mysql.endpoint   # Direct resource reference
}
