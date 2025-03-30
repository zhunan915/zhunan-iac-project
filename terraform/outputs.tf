output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "app_instance_ids" {
  description = "IDs of the 6 private EC2 instances"
  value       = concat(aws_instance.ubuntu_app[*].id, aws_instance.amazon_app[*].id)
}

output "ubuntu_private_ips" {
  value = aws_instance.ubuntu_app[*].private_ip
}

output "amazon_private_ips" {
  value = aws_instance.amazon_app[*].private_ip
}

output "ansible_controller_private_ip" {
  value = aws_instance.ansible_controller.private_ip
}
