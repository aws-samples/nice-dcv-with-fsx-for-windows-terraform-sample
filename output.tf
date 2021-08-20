output "instance_ips" {
  value = module.windows.instance_ips
}

output "fsx_dns_name" {
  value = module.fsx.fsx_domain_name
}
