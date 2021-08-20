output "security_group_id" {
  value = aws_security_group.client.id
}

output "fsx_domain_name" {
  value = aws_fsx_windows_file_system.this.dns_name
}
