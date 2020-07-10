resource "aws_eks_cluster" "eks-cluster" {
  name = var.cluster-name
  role_arn = aws_iam_role.eks-role.arn
  version = "1.16"
  vpc_config {
    subnet_ids = [
      aws_subnet.az-1-public.id,
      aws_subnet.az-1-private.id,
      aws_subnet.az-2-public.id,
      aws_subnet.az-2-private.id
    ]
    security_group_ids = [
      aws_security_group.common-security.id]
    public_access_cidrs = ["0.0.0.0/0"]
  }
}

locals {
  common-userdata = {
    cluster_auth_base64 = aws_eks_cluster.eks-cluster.certificate_authority[0].data
    cluster_endpoint = aws_eks_cluster.eks-cluster.endpoint
    cluster_name = aws_eks_cluster.eks-cluster.name
  }
}

module "spot-ingress" {
  source = "./modules/asg"
  common-userdata = local.common-userdata
  kubelet_extra_args = var.ingress.kubelet_extra_args
  bootstrap_extra_args = var.ingress.bootstrap_extra_args
  security-groups = [aws_security_group.common-security.id, aws_security_group.ingress.id]
  asg-count = 2
  asg-name = "sysadminka-ingress"
  launch-template = {
    image-id = "ami-030f9071e0d32b989"
    name = "sysadminka-ingress"
    type = "t3.medium"
    worker-profile = aws_iam_instance_profile.worker-profile.name
    volume-size =  20
    volume-type = "gp2"
    key-name = aws_key_pair.aws-key.key_name
    spot-price = "0.05"
  }
    tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.eks-cluster.name}" = "owned"
    role = "ingress"
    Name = "spot-ingress"
  }
  availability-zones = [var.az-1, var.az-2]
  subnets = [aws_subnet.az-1-public.id, aws_subnet.az-2-public.id]
  tg-arns = [aws_lb_target_group.ingress-http.arn, aws_lb_target_group.ingress-https.arn]
}

module "spot-worker" {
  source = "./modules/asg"
  common-userdata = local.common-userdata
  kubelet_extra_args = var.worker.kubelet_extra_args
  bootstrap_extra_args = var.worker.bootstrap_extra_args
  security-groups = [aws_security_group.common-security.id]
  asg-count = 1
  asg-name = "sysadminka-worker"
  launch-template = {
    image-id = "ami-030f9071e0d32b989"
    name = "sysadminka-worker"
    type = "t3.medium"
    worker-profile = aws_iam_instance_profile.worker-profile.name
    volume-size =  20
    volume-type = "gp2"
    key-name = aws_key_pair.aws-key.key_name
    spot-price = "0.05"
  }
  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.eks-cluster.name}" = "owned"
    role = "worker"
    Name = "spot-worker"
  }
  availability-zones = [var.az-1, var.az-2]
  subnets = [aws_subnet.az-1-private.id, aws_subnet.az-2-private.id]
}
