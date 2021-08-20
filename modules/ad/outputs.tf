output "domain_join_ssm_document" {
  value = aws_ssm_document.this
}

output "active_directory_id" {
  value = aws_directory_service_directory.this.id
}
