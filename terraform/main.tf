provider "aws" {
  region = var.aws_region
}

# Create a new VPC using the official module from the Terraform Registry
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

# --- Bastion Host Setup ---
# Create a security group for the bastion host, allowing SSH only from your IP.
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_allowed_ip]   # e.g., "X.X.X.X/32"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Provision the bastion host in a public subnet.
resource "aws_instance" "bastion" {
  ami                         = "ami-01f5a0b78d6089704"  # Amazon Linux 2 AMI for bastion
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  key_name                    = var.key_name

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "BastionHost"
  }
}

# --- Private EC2 Instances Setup ---
# Create a security group for the private EC2 instances.
resource "aws_security_group" "private_sg" {
  name   = "private-sg"
  vpc_id = module.vpc.vpc_id

  # Allow SSH from the bastion host's security group.
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

# Create 6 EC2 instances in private subnets using the custom AMI from Packer.
resource "aws_instance" "app" {
  count                  = 6
  ami                    = "ami-033902bac590411ea"
  instance_type          = "t2.micro"
  subnet_id              = element(module.vpc.private_subnets, count.index % length(module.vpc.private_subnets))
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = {
    Name = "AppInstance-${count.index + 1}"
  }
}
