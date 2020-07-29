data "template_file" "template-aws-auth" {
  template = file("templates/aws-auth.yml.tpl")
  vars = {
    arn = aws_iam_role.worker-role.arn
  }
}

resource "kubernetes_config_map" "aws-auth" {
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = data.template_file.template-aws-auth.rendered
  }
}

resource "helm_release" "ingress" {
  chart = "nginx-ingress"
  name = "nginx-ingress"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  namespace = "ingress"
  create_namespace = true
  values = [
    file("files/ingress-vars.yml")
  ]
}

resource "helm_release" "spot-handler" {
  chart = "aws-node-termination-handler"
  name = "aws-node-termination-handler"
  repository = "https://aws.github.io/eks-charts"
  namespace = "kube-system"
  set {
    name = "nodeSelector.node\\.kubernetes\\.io/lifecycle"
    value = "spot"
  }
}

resource "helm_release" "eventrouter" {
  chart = "eventrouter"
  name = "eventrouter"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  namespace = "kube-system"
  set {
    name = "sink"
    value = "stdout"
  }
  set {
    name = "nodeSelector.node\\.kubernetes\\.io/role"
    value = "worker"
  }
}