provider "aws" {
  region  = var.region
}

provider "kubernetes" {
  host = aws_eks_cluster.eks-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks-cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.eks-auth.token
  load_config_file = false
}

provider "helm" {
    kubernetes {
    host = aws_eks_cluster.eks-cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks-cluster.certificate_authority.0.data)
    token = data.aws_eks_cluster_auth.eks-auth.token
    load_config_file = false
  }
}

data "aws_eks_cluster_auth" "eks-auth" {
  name = aws_eks_cluster.eks-cluster.name
}

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