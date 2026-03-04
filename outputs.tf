output "ec2_connect_command" {
  value = "ssh ec2-user@${module.compute.public_ip}"
}

output "db_endpoint" {
  value = module.database.rds_endpoint
}
