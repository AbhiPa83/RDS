variable "vpc_id" {
  description = "The VPC ID where the EC2 will be deployed"
  type        = string
}

variable "public_subnet" {
  description = "The public subnet ID for the EC2"
  type        = string
}
