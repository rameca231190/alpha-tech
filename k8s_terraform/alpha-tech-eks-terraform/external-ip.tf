data "http" "workstation-external-ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  workstation-external-cidr = format("%s/32", chomp(data.http.workstation-external-ip.body))
}