provider "aws" {
  region  = var.region
}

provider "kubernetes" {}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "aws-key" {
  public_key = tls_private_key.ssh-key.public_key_openssh
  key_name = "sysadminka-key"
}

output "key" {
  value = tls_private_key.ssh-key.private_key_pem
}