provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "custom-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Project = "custom-ami"
  }
}

resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_allowed_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = "ami-01f5a0b78d6089704"
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "BastionHost"
    Role = "bastion"
  }
}

resource "aws_security_group" "private_sg" {
  name   = "private-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ubuntu_app" {
  count         = 3
  ami           = "ami-0f9de6e2d2f067fca"
  instance_type = "t2.micro"
  subnet_id     = element(module.vpc.private_subnets, count.index)
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  tags = {
    Name = "UbuntuApp-${count.index + 1}"
    OS   = "ubuntu"
  }
}

resource "aws_instance" "amazon_app" {
  count         = 3
  ami           = "ami-01f5a0b78d6089704"
  instance_type = "t2.micro"
  subnet_id     = element(module.vpc.private_subnets, count.index)
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  tags = {
    Name = "AmazonApp-${count.index + 1}"
    OS   = "amazon"
  }
}

resource "aws_instance" "ansible_controller" {
  ami           = "ami-0f9de6e2d2f067fca"
  instance_type = "t2.micro"
  subnet_id     = module.vpc.private_subnets[0]
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  tags = {
    Name = "AnsibleController"
  }
}
