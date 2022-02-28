##################################################################################
# TERRAFORM CONFIG
##################################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.2.0"
    }
  }
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region                   = var.region
  shared_credentials_files = var.aws_creds_file
  profile                  = var.aws_profile
}
