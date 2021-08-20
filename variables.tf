variable "region" {
  description = "AWS region to which you deploy this sample."
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets_cidr" {
  description = "CIDR for the private subnets in the VPC. You must specify two CIDRs."
  type        = list(string)
  default = [
    "10.0.0.0/24",
    "10.0.1.0/24"
  ]
}

variable "public_subnets_cidr" {
  description = "CIDR for the public subnets in the VPC. You must specify two CIDRs."
  type        = list(string)
  default = [
    "10.0.100.0/24",
    "10.0.101.0/24"
  ]
}

variable "windows_instance_type" {
  description = "EC2 instance type for the windows instance. Please refer to: https://aws.amazon.com/jp/ec2/instance-types/"
  type        = string
  default     = "t3.medium"
}

variable "windows_ami_id" {
  description = "AMI ID to use when launching the windows instance. We recommend to use AMIs in which NICE DCV server is pre-installed. They also provide AMIs with GPU drivers. Please refer to the link for the actual AMI IDs of your region: https://console.aws.amazon.com/ec2/v2/home?#Images:visibility=public-images;search=dcv;sort=name"
  type        = string
  default     = "ami-0df133300b55a08a4"
}

variable "allowed_cidr" {
  description = "CIDR from which you can access NICE DCV instances."
  type        = list(string)
  default     = ["10.0.0.0/32"]
}

variable "fsx_storage_capacity" {
  description = "Storage capacity(GB) of FSx drive."
  type        = number
  default     = 32
}

variable "fsx_throughput_capacity" {
  description = "Throughput capacity(Mbps) of FSx drive."
  type        = number
  default     = 8
}

variable "domain_name" {
  description = "Domain name for Active Directory."
  type        = string
  default     = "corp.anexample.com"
}

variable "admin_password" {
  description = "Admin password for Active Directory."
  type        = string
  default     = "Passw0rd"
}
