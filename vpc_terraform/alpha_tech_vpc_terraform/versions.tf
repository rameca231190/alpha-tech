
terraform {
  required_version = ">= 0.13.0"
  required_providers {
    archive = {
      source = "hashicorp/archive"
      version = "~>2.2.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~>3.0"
    }
    template = {
      source = "hashicorp/template"
      version = "~>2.2.0"
    }
  }
}
