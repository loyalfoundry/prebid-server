output "prebid_server_vpc_id" {
  value       = aws_vpc.prebid_server_vpc.id
  description = "The ID of the prebid_server VPC."
}

output "prebid_server_vpc_cidr_block" {
  value       = aws_vpc.prebid_server_vpc.cidr_block
  description = "The CIDR block of the prebid_server VPC."
}

output "prebid_server_subnet_1_id" {
  value       = aws_subnet.prebid_server_subnet_1.id
  description = "The ID of the newly created subnet in the prebid_server VPC."
}

output "prebid_server_subnet_2_id" {
  value       = aws_subnet.prebid_server_subnet_2.id
  description = "The ID of the newly created subnet in the prebid_server VPC."
}

output "prebid_server_public_subnet_a_id" {
  value       = aws_subnet.prebid_server_public_a.id
  description = "The ID of the public subnet in the prebid_server VPC."
}

output "prebid_server_public_subnet_b_id" {
  value       = aws_subnet.prebid_server_public_b.id
  description = "The ID of the public subnet in the prebid_server VPC."
}
