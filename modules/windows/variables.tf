variable "vpc" {}

variable "domain_join_ssm_document" {}

variable "instance_type" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "allowed_cidr" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}
