output "app_instance_public_ip" {
  description = "The public IP of the instance"
  value       = aws_instance.prebid_server.public_ip
}

output "app_instance_public_dns" {
  description = "The public DNS of the instance"
  value       = aws_instance.prebid_server.public_dns
}
