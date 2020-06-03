variable "common-userdata" {
  type = map(string)
  default = {
    cluster_auth_base64 =  ""
    cluster_endpoint = ""
    cluster_name = ""
  }
}

variable "kubelet_extra_args" {
  type = string
  default = ""
}

variable "bootstrap_extra_args" {
  type = string
  default = ""
}

variable "launch-template" {
  type = map(string)
  default = {
    image-id = ""
    name = ""
    type = ""
    worker-profile = ""
    volume-size = ""
    volume-type = ""
    key-name = ""
    spot-price = ""
  }
}

variable "security-groups" {
  type = list(string)
  default = []
}

variable "asg-count" {
  type = string
  default = ""
}

variable "asg-name" {
  type = string
  default = ""
}

variable "availability-zones" {
  type = list(string)
  default = []
}

variable "subnets" {
  type = list(string)
  default = []
}

variable "tg-arns" {
  type = list(string)
  default = []
}

variable "tags" {
  type = map(string)
  default = {}
}
