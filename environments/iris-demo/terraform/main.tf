terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

variable "environment_root" {
  type = string
}

variable "cluster_name" {
  default = "testohpc"
}

variable "key_pair" {
  type = string
}

variable "network" {
  type = string
}

variable "login_flavor" {
  type = string
}

variable "login_image" {
  type = string
}

variable "compute_count" {
  default = 2
}

variable "compute_flavor" {
  type = string
}

variable "compute_image" {
  type = string
}

variable "control_flavor" {
  type = string
}

variable "control_image" {
  type = string
}

variable "external_network" {
  type = string
  description = "Name of external network"
}

resource "openstack_compute_instance_v2" "login" {

  name = "${var.cluster_name}-login-0"
  image_name = var.login_image
  flavor_name = var.login_flavor
  key_pair = var.key_pair
  network {
    name = var.network
  }
}

resource "openstack_compute_instance_v2" "control" {

  name = "${var.cluster_name}-control-0"
  image_name = var.control_image
  flavor_name = var.control_flavor
  key_pair = var.key_pair
  network {
    name = var.network
  }
}

resource "openstack_compute_instance_v2" "compute" {

  count = var.compute_count

  name = "${var.cluster_name}-compute-${count.index}"
  image_name = var.compute_image
  flavor_name = var.compute_flavor
  key_pair = var.key_pair
  network {
    name = var.network
  }
}

# Associate a floating IP

data "openstack_networking_network_v2" "external_network" {
  network_id = var.external_network
}

resource "openstack_networking_floatingip_v2" "login" {
  pool = data.openstack_networking_network_v2.external_network.name
  subnet_id = "273123bb-70f6-4f51-a406-7fc4b446532d"
}

resource "openstack_compute_floatingip_associate_v2" "login" {
  floating_ip = openstack_networking_floatingip_v2.login.address
  instance_id = openstack_compute_instance_v2.login.id
}

# TODO: needs fixing for case where creation partially fails resulting in "compute.network is empty list of object"
resource "local_file" "hosts" {
  content  = templatefile("${path.module}/inventory.tpl",
                          {
                            "cluster_name": var.cluster_name
                            "login": openstack_compute_instance_v2.login,
                            "proxy": openstack_networking_floatingip_v2.login.address,
                            "control": openstack_compute_instance_v2.control,
                            "computes": openstack_compute_instance_v2.compute,
                          },
                          )
  filename = "${var.environment_root}/inventory/hosts"
}
