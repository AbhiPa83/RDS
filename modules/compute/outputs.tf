output "ec2_sg_id" { value = aws_security_group.ec2_sg.id }
output "public_ip" { value = aws_instance.app_server.public_ip }
output "instance_id" {
  description = "The ID of the App Server"
  value       = aws_instance.app_server.id
}
