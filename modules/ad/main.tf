resource "aws_directory_service_directory" "this" {
  name        = var.domain_name
  password    = var.admin_password
  edition     = "Standard"
  type        = "MicrosoftAD"
  description = "AD for NICE DCV FSx sample"

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = var.subnet_ids
  }
}

# SSM document to join the AD domain
resource "aws_ssm_document" "this" {
  name          = "domain_join_${aws_directory_service_directory.this.name}"
  document_type = "Command"

  content = jsonencode(
    {
      "schemaVersion" = "2.2"
      "description"   = "Automatic domain join"
      "mainSteps" = [
        {
          "action" = "aws:domainJoin",
          "name"   = "domainJoin",
          "inputs" = {
            "directoryId" : aws_directory_service_directory.this.id,
            "directoryName" : aws_directory_service_directory.this.name
            "dnsIpAddresses" : sort(aws_directory_service_directory.this.dns_ip_addresses)
          }
        }
      ]
    }
  )
}
