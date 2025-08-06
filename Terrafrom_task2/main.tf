terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # or a version you know works
    }
  }
}

provider "aws" {
  alias  = "us_east"
  region = "us-east-2"
}

provider "aws" {
  alias  = "ap_south"
  region = "ap-south-1"
}

resource "aws_instance" "ec2_us_east" {
  provider      = aws.us_east
  ami           = var.ami_us_east
  instance_type = var.instance_type
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install nginx -y
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF

  tags = {
    Name = "EC2-US-East"
  }
}

resource "aws_instance" "ec2_ap_south" {
  provider      = aws.ap_south
  ami           = var.ami_ap_south
  instance_type = var.instance_type
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install nginx -y
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF

  tags = {
    Name = "EC2-AP-South"
  }
}

# variable_Block
variable "instance_type" {
  default = "t2.micro"
}

variable "ami_us_east" {
  description = "AMI ID for us-east-2 region"
  default     = "ami-0d1b5a8c13042c939"
}

variable "ami_ap_south" {
  description = "AMI ID for ap-south-1 region"
  default     = "ami-03f4878755434977f"
}