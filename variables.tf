variable "cluster-name" {
  type = string
  default = "sysadminka"
}

variable "region" {
  type = string
  default = "eu-north-1"
}

variable "az-1" {
  type = string
  default = "eu-north-1a"
}

variable "az-2" {
  type = string
  default = "eu-north-1b"
}

variable "ingress" {
  type = map(string)
  default = {
    bootstrap_extra_args = "--enable-docker-bridge true"
    kubelet_extra_args = "--node-labels node.kubernetes.io/role=ingress,node.kubernetes.io/lifecycle=spot"
  }
}

variable "worker" {
  type = map(string)
  default = {
    bootstrap_extra_args = "--enable-docker-bridge true"
    kubelet_extra_args = "--node-labels node.kubernetes.io/role=worker,node.kubernetes.io/lifecycle=spot"
  }
}
variable "network" {
  type = map(string)
  default = {
    vpc-cidr = "192.168.0.0/16",
    az-1-private = "192.168.20.0/24",
    az-1-public = "192.168.10.0/24",
    az-2-private = "192.168.21.0/24",
    az-2-public = "192.168.11.0/24"
  }
}

variable "admin_access_list" {
  type = list(string)
  default = [
    "1.1.1.1/32"
  ]
}