data "template_file" "userdata" {
  template = file("templates/userdata.sh.tpl")
  vars = {
    cluster_auth_base64 = var.common-userdata.cluster_auth_base64
    endpoint = var.common-userdata.cluster_endpoint
    bootstrap_extra_args = var.bootstrap_extra_args
    kubelet_extra_args = var.kubelet_extra_args
    cluster_name = var.common-userdata.cluster_name
  }
}


resource "aws_autoscaling_group" "ebs-asg" {
  name = var.asg-name
  max_size = var.asg-count
  min_size = var.asg-count
  availability_zones = var.availability-zones
  launch_template {
    name = aws_launch_template.spot-template.name
    version = aws_launch_template.spot-template.latest_version
  }
  target_group_arns = var.tg-arns
  dynamic "tag" {
    for_each = var.tags
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
  vpc_zone_identifier = var.subnets
}