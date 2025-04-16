
terraform {
  required_providers{
    aws = {
	  source = "hashicorp/aws"
	  version = "~> 4.16"
	
	}
  }
    
	  required_version = ">= 1.2.0"
}

  provider "aws" {
    region = "us-east-1"
  }
  
#   data "aws_ami" "ubuntu" {
#   most_recent = true

#   owners = ["099720109477"] # Canonical's AWS account

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

  
  resource "aws_instance" "app_server" {
    ami           = "ami-084568db4383264d4"
    instance_type = "t2.micro"
    key_name      = "aws-new"
    security_groups = [aws_security_group.allow_ssh_web.name]
    

    user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io curl
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              EOF
  tags = {
    Name = "django-microservice"
  }
}

resource "aws_security_group" "allow_ssh_web" {
  name        = "allow_ssh_web"
  description = "Allow SSH and Web traffic"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

