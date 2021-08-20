variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "storage_capacity" {
  type = string
}

variable "throughput_capacity" {
  type = string
}

variable "active_directory_id" {
  type = string
}
