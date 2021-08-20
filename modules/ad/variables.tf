variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "domain_name" {
  type = string
}

variable "admin_password" {
  type = string
}
