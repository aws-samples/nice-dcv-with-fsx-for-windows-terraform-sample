output "instance_ips" {
  value = module.ec2_windows.*.public_ip
}
