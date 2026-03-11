provider "aws" {
  region = "us-east-1"
}

module "network" {
  source   = "./modules/network"
  vpc_cidr = "192.168.1.0/24"
}

module "compute" {
  source        = "./modules/compute"
  vpc_id        = module.network.vpc_id
  public_subnet = module.network.public_subnet_id
}

module "database" {
  source        = "./modules/database"
  vpc_id        = module.network.vpc_id
  db_subnet_ids = module.network.db_subnet_ids
  ec2_sg_id     = module.compute.ec2_sg_id
}

resource "aws_iam_role" "eb_scheduler_role" {
  name = "eb_scheduler_role"
  assume_role_policy = jsonencode({
    version = 2012-10-17
    statement = [{
      Effect    = "Allow"
      Principal = { Service = "scheduler.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "eb_scheduler_policy" {
  name = "eb_scheduler-policy"
  role = aws_iam_role.eb_scheduler_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:StartInstances",
        "ec2:StopInstances",
        "rds:StartDBInstance",
        "rds:StopDBInstance"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_scheduler_schedule" "stop_ec2" {
  name       = "stop-ec2-evening"
  group_name = "default"
  flexible_time_window {
    mode = "off"
  }
  schedule_expression          = "cron(0 19 * * ? *)"
  schedule_expression_timezone = "Asia/Kolkata"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.eb_scheduler_role.arn
    input = jsonencode({
      InstanceIds = [module.compute.instance_id]
    })
  }
}

resource "aws_scheduler_schedule" "stop_rds" {
  name       = "stop-rds-evening"
  group_name = "default"
  flexible_time_window {
    mode = "off"
  }
  schedule_expression          = "cron(0 19 * * ? *)"
  schedule_expression_timezone = "Asia/Kolkata"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBInstance"
    role_arn = aws_iam_role.eb_scheduler_role.arn
    input = jsonencode({
      DBInstanceIdentifier = module.database.db_id
    })
  }
}

resource "aws_scheduler_schedule" "start_ec2" {
  name       = "start-ec2-morning"
  group_name = "default"
  flexible_time_window {
    mode = "off"
  }
  schedule_expression          = "cron(0 7 * * ? *)"
  schedule_expression_timezone = "Asia/Kolkata"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.eb_scheduler_role.arn
    input = jsonencode({
      InstanceIds = [module.compute.instance_id]
    })
  }
}

resource "aws_scheduler_schedule" "start_rds" {
  name       = "start-rds-morning"
  group_name = "default"
  flexible_time_window {
    mode = "off"
  }
  schedule_expression          = "cron(0 7 * * ? *)"
  schedule_expression_timezone = "Asia/Kolkata"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBInstance"
    role_arn = aws_iam_role.eb_scheduler_role.arn
    input = jsonencode({
      DBInstanceIdentifier = module.database.db_id
    })
  }
}
