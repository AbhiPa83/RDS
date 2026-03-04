resource "aws_db_subnet_group" "main" {
  name       = "db-subnet-group"
  subnet_ids = var.db_subnet_ids
}

resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ec2_sg_id] # Traffic only allowed from EC2
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  db_name              = "maindb"
  username             = "admin"
  password             = "TestingRDS123#" # Change this!
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true
}
