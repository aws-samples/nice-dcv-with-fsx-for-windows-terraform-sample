data "aws_region" "current" {
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name_prefix        = "ec2_windows_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
  ]

  inline_policy {
    # https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-license.html
    name = "allow_access_to_nice_dcv_license"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::dcv-license.${data.aws_region.current.name}/*"
        },
      ]
    })
  }
}

resource "aws_iam_instance_profile" "this" {
  role = aws_iam_role.this.name
}

resource "aws_security_group" "ec2" {
  description = "Allow NICE DCV server access"
  vpc_id      = var.vpc.vpc_id
  name_prefix = "nice_dcv_server_"

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr
    description = "NICE DCV"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
  }

  tags = {
    Name = "windows_nice_dcv_server"
  }
}

# CloudWatch Agent configuration file
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-Configuration-File-Details.html
data "template_file" "cloudwatch_agent_config_json" {
  template = file("${path.module}/cloudwatch_agent_config.json")
}

resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  name  = "/ec2/windows/nice_dcv_sample/cloudwatch_agent_config"
  type  = "String"
  value = data.template_file.cloudwatch_agent_config_json.rendered
}

# Install and start CloudWatch Agent
resource "aws_ssm_document" "enable_cloudwatch_agent" {
  name          = "enable_cloudwatch_agent"
  document_type = "Command"

  content = jsonencode(
    {
      "schemaVersion" = "2.2"
      "description"   = "Enable AmazonCloudWatchAgent"
      "mainSteps" = [
        {
          "action" : "aws:runDocument",
          "name" : "Install_CloudWatch_Agent",
          "inputs" : {
            "documentType" : "SSMDocument",
            "documentPath" : "AWS-ConfigureAWSPackage",
            "documentParameters" : {
              "action" : "Install",
              "name" : "AmazonCloudWatchAgent",
            }
          }
        },
        {
          "action" : "aws:runDocument",
          "name" : "Configure_CloudWatch_Agent",
          "inputs" : {
            "documentType" : "SSMDocument",
            "documentPath" : "AmazonCloudWatch-ManageAgent",
            "documentParameters" : {
              "optionalConfigurationLocation" : aws_ssm_parameter.cloudwatch_agent_config.name,
            }
          }
        }
      ]
    }
  )
}

resource "aws_ssm_document" "initialize_nice_dcv_instance" {
  name          = "initialze_nice_dcv_instance"
  document_type = "Command"

  content = jsonencode(
    {
      "schemaVersion" = "2.2"
      "description"   = "Enable AmazonCloudWatchAgent"
      "mainSteps" = [
        {
          "action" : "aws:runDocument",
          "name" : "join_ad_domain",
          "inputs" : {
            "documentType" : "SSMDocument",
            "documentPath" : var.domain_join_ssm_document.name,
          }
        },
        {
          "action" : "aws:runDocument",
          "name" : "enable_cloudwatch_agent",
          "inputs" : {
            "documentType" : "SSMDocument",
            "documentPath" : aws_ssm_document.enable_cloudwatch_agent.name,
          }
        }
      ]
    }
  )
}

resource "aws_ssm_association" "initialize_nice_dcv" {
  name = aws_ssm_document.initialize_nice_dcv_instance.name

  targets {
    key    = "tag:InitializeAsNiceDcvInstance"
    values = ["true"]
  }
}

data "template_file" "userdata" {
  template = file("${path.module}/userdata.bat")
}

module "ec2_windows" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name                   = "windows-nice-dcv"
  instance_count         = 1
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = concat([aws_security_group.ec2.id], var.security_group_ids)
  subnet_ids             = var.vpc.public_subnets
  iam_instance_profile   = aws_iam_instance_profile.this.name
  user_data              = data.template_file.userdata.rendered

  tags = {
    InitializeAsNiceDcvInstance = "true"
  }

  root_block_device = [{
    encrypted   = true
    volume_size = 50 # GB, C drive capacity
    volume_type = "gp3"
  }]
}
