# Create common rules for the cluster

resource "aws_security_group" "common-security" {
  name = "common-security"
  description = "eks-common"
  vpc_id = aws_vpc.cluster-vpc.id
  tags = {
    "kubernetes.io/cluster/${var.cluster-name}" = "owned"
  }
}

resource "aws_security_group_rule" "allow-admin" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.common-security.id
  to_port = 0
  type = "ingress"
  cidr_blocks = var.admin_access_list
}

resource "aws_security_group_rule" "allow-internal" {
  from_port = 0
  protocol = "-1"
  self = true
  to_port = 0
  type = "ingress"
  security_group_id = aws_security_group.common-security.id
}

resource "aws_security_group_rule" "egress" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.common-security.id
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

# Creating rules for the ingress group

resource "aws_security_group" "ingress" {
  name = "sysadminka-ingress"
  description = "sysadminka-eks-common"
  vpc_id = aws_vpc.cluster-vpc.id
  tags = {
    Name = "sysadminka-common"
  }
}

resource "aws_security_group_rule" "allow-http" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.ingress.id
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow-https" {
  from_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.ingress.id
  to_port = 443
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}