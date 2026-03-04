output "vpc_id" { value = aws_vpc.main.id }
output "public_subnet_id" { value = aws_subnet.public.id }
output "db_subnet_ids" { value = [aws_subnet.db_1.id, aws_subnet.db_2.id] }
