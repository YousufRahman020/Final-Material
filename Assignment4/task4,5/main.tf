terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}


data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "cs423-assignment4-key"
  public_key = file("cs423-assignment4-key.pub")
}

data "aws_subnet" "cs423-devopspublic-2" {
  filter {
    name   = "tag:Name"
    values = ["cs423-devopspublic-2"]
  }
}

data "aws_subnet" "cs423-devopspublic-1" {
  filter {
    name   = "tag:Name"
    values = ["cs423-devopspublic-1"]
  }
}



resource "aws_instance" "ec2_instance_website" {
  ami                         = data.aws_ami.latest_ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  subnet_id                   = data.aws_subnet.cs423-devopspublic-2.id
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              EOF

  tags = {
    Name = "Assignment4-EC2-Web"
  }
}

resource "aws_instance" "ec2_instance_database" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ec2_key_pair.key_name
  subnet_id     = data.aws_subnet.cs423-devopspublic-1.id

  user_data = <<-EOF
              #!/bin/bash
              EOF

  tags = {
    Name = "Assignment4-EC2-DB-ML"
  }
}

output "private_key" {
  value       = aws_key_pair.ec2_key_pair.key_name
  description = "Private key for the created key pair"
}

#task5 part
output "web_instance_ips" {
  value = {
    public_ip  = aws_instance.ec2_instance_website.public_ip
    private_ip = aws_instance.ec2_instance_website.private_ip
  }
}

output "db_ml_instance_ips" {
  value = {
    public_ip  = aws_instance.ec2_instance_database.public_ip
    private_ip = aws_instance.ec2_instance_database.private_ip
  }
}
output "iam_user_details" {
  value = {
    user_name = "terraform-cs423-devops"
  }
}