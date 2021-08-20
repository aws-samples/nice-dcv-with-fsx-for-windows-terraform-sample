resource "aws_security_group" "client" {
  description = "Allow FSx access"
  vpc_id      = var.vpc_id
  name_prefix = "fsx_client_"
  tags = {
    Name = "fsx_client"
  }
}

resource "aws_security_group" "server" {
  description = "Allow FSx access from allowed security groups"
  vpc_id      = var.vpc_id
  name_prefix = "fsx_server_"

  # https://docs.aws.amazon.com/fsx/latest/WindowsGuide/limit-access-security-groups.html#fsx-vpc-security-groups
  ingress {
    description     = "Allow Fsx access from allowed security groups"
    from_port       = 445
    to_port         = 445
    protocol        = "tcp"
    security_groups = [aws_security_group.client.id]
  }

  ingress {
    description     = "Allow Fsx access from allowed security groups"
    from_port       = 5985
    to_port         = 5985
    protocol        = "tcp"
    security_groups = [aws_security_group.client.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fsx_server"
  }
}

resource "aws_fsx_windows_file_system" "this" {
  active_directory_id = var.active_directory_id
  subnet_ids          = var.subnet_ids
  storage_capacity    = var.storage_capacity
  throughput_capacity = var.throughput_capacity
  deployment_type     = "MULTI_AZ_1"
  security_group_ids  = [aws_security_group.server.id]
  preferred_subnet_id = var.subnet_ids[0]
  tags = {
    Name = "nice-dcv-sample"
  }
}
