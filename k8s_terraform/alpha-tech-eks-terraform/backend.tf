terraform {
  backend "s3" {
    region         = "ap-southeast-1"
    bucket         = "vpc-tfstate-alpha-tech"
    key            = "qa-eks/terraform.tfstate"
    dynamodb_table = "terraform-locks-alpha-tech"
    encrypt        = true
  }
}