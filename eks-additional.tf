data "template_file" "template-aws-auth" {
  template = file("templates/aws-auth.yml.tpl")
  vars = {
    arn = aws_iam_role.worker-role.arn
  }
}

resource "local_file" "create-auth" {
  content = data.template_file.template-aws-auth.rendered
  filename = "./tmp/aws-auth.yml"
}

resource "null_resource" "get-kubectl" {
  triggers = {
    always_run = timestamp()
  }
  depends_on = [local_file.create-auth]
  provisioner "local-exec" {
    command = "cd ./tmp && curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/linux/amd64/kubectl && chmod +x ./kubectl"
  }
}

resource "null_resource" "get-kubeconfig" {
  triggers = {
    always_run = timestamp()
  }
  depends_on = [aws_eks_cluster.eks-cluster, null_resource.get-kubectl]
  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${aws_eks_cluster.eks-cluster.name}"
  }
}

resource "kubernetes_config_map" "aws-auth" {
  depends_on = [null_resource.get-kubeconfig, local_file.create-auth]
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = file("./tmp/aws-auth.yml")
  }
}
