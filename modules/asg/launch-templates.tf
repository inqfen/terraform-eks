resource "aws_launch_template" "spot-template" {
  name = var.launch-template.name
  ebs_optimized = true
  image_id = var.launch-template.image-id
  instance_type = var.launch-template.type
  iam_instance_profile {
    name = var.launch-template.worker-profile
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.launch-template.volume-size
      volume_type = var.launch-template.volume-type
      delete_on_termination = true
    }
  }

  key_name = var.launch-template.key-name
  vpc_security_group_ids = var.security-groups
  user_data = base64encode(data.template_file.userdata.rendered)
  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = var.launch-template.spot-price
    }
  }
}