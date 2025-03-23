variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Allowed IP for SSH access to the bastion host (your public IP).
variable "bastion_allowed_ip" {
  type    = string
  default = "157.131.204.74/32"  
}

# The key name you use in AWS for SSH access.
variable "key_name" {
  type    = string
  default = "zhunan-new" 
}

# The AMI ID for the bastion host (use a known Amazon Linux 2 AMI).
variable "bastion_ami_id" {
  type    = string
  default = "ami-01f5a0b78d6089704"  
}

# The custom AMI ID from your Packer build.
variable "custom_ami_id" {
  type    = string
  default = "ami-033902bac590411ea"  
}
