variable "cluster-name" {
  default = "terraform-eks-dev"
  type    = string
}
variable "vpc_id" {
  type    = string
}
variable "env" {
  type    = string
}
variable "region" {
  type    = string
}

variable "private_subnets" {
  type    = list
}

variable "image_id" {
  type    = string
}



