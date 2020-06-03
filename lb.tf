resource "aws_lb" "ingress-lb" {
  name = "sysadminks-eks-lb"
  internal = false
  load_balancer_type = "network"
  subnets = [
    aws_subnet.az-1-public.id, aws_subnet.az-2-public.id
    ]
  tags = {
    Name = "sysadminka-eks-balancer"
  }
}

resource "aws_lb_listener" "http-listener" {
  load_balancer_arn = aws_lb.ingress-lb.arn
  port = 80
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ingress-http.arn

  }
}

resource "aws_lb_listener" "https-listener" {
  load_balancer_arn = aws_lb.ingress-lb.arn
  port = 443
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ingress-https.arn
  }
}

resource "aws_lb_target_group" "ingress-http" {
  name = "sysadminka-eks-http"
  port = 80
  protocol = "TCP"
  vpc_id = aws_vpc.cluster-vpc.id
}

resource "aws_lb_target_group" "ingress-https" {
  name = "sysadminka-eks-https"
  port = 443
  protocol = "TCP"
  vpc_id = aws_vpc.cluster-vpc.id
}