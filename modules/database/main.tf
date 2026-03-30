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
  allocated_storage               = 20
  engine                          = "mysql"
  instance_class                  = "db.t2.micro"
  db_name                         = "maindb"
  username                        = "admin"
  password                        = "TestingRDS123#" # Change this!
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [aws_security_group.rds_sg.id]
  skip_final_snapshot             = true
  parameter_group_name            = aws_db_parameter_group.mysql_logs.name
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_alarm" {
  alarm_name          = "rds-high-cpu-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "60"
  alarm_description   = "The metric monitors RDS CPU utilization"
  dimensions = {
    DBINstanceIdentifier = aws_db_instance.mysql.id
  }
}

resource "aws_db_parameter_group" "mysql_logs" {
  name   = "mysal-logging-params"
  family = "mysql8.4"

  parameter {
    name  = "general_log"
    value = "1"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2" # Log queries taking longer than 2 seconds
  }

  parameter {
    name  = "log_output"
    value = "FILE" # This allows AWS to pick up the files for CloudWatch
  }

}

resource "aws_sns_topic" "alerts" {
  name = "rds-alerts-topic"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "abhipa83@outlook.com" # Put your real email here
}
