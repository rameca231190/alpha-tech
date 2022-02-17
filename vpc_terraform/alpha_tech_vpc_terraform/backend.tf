terraform {
  backend "s3" {
    bucket = "vpc-tfstate-alpha-tech"
    key    = "dev-vpc/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
