terraform {
  backend "s3" {
    bucket         = "vpc-tfstate-alpha-tech"
    key            = "dev-vpc/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-locks-alpha-tech"
    encrypt        = true
  }
}
