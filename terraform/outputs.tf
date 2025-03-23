output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "app_instance_ids" {
  description = "IDs of the 6 private EC2 instances"
  value       = aws_instance.app.*.id
}
