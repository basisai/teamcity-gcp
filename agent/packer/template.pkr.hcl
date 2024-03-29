packer {
  required_version = ">= 1.7.2"
  required_plugins {
    googlecompute = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

variable "additional_configuration" {
  description = "Additional configuration in buildAgent.properties for TeamCity"
  type        = string
  default     = ""
}

variable "disk_size" {
  type    = string
  default = "10"
}

variable "docker_compose_version" {
  type    = string
  default = "1.29.2"
}

variable "docker_version" {
  type    = string
  default = "5:20.10.8~3-0~ubuntu-focal"
}

variable "image_base_name" {
  type    = string
  default = "teamcity-agent"
}

variable "install_stackdriver_agent" {
  type    = string
  default = "false"
}

variable "install_telegraf" {
  type    = string
  default = "false"
}

variable "machine_type" {
  type    = string
  default = "n1-standard-1"
}

variable "network_project_id" {
  type = string
}

variable "omit_external_ip" {
  type    = string
  default = "true"
}

variable "project_id" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "teamcity_base_url" {
  type = string
}

variable "teamcity_user" {
  type    = string
  default = "teamcity"
}

variable "use_internal_ip" {
  type    = string
  default = "true"
}

variable "zone" {
  type = string
}

variable "ansible_python_interpreter" {
  description = "Python interpreter path which was used to install Ansible"
  type        = string
  default     = "/usr/bin/python3"
}

locals {
  packer_build_time = lower(formatdate("YYYY-MM-DD'T'hh-mm-ssZ", timestamp()))
}

source "googlecompute" "ubuntu-teamcity-agent" {
  disable_default_service_account = true

  disk_size         = var.disk_size
  image_description = "TeamCity agent built at ${local.packer_build_time}"
  image_family      = var.image_base_name
  image_labels = {
    packer    = "true"
    timestamp = "${local.packer_build_time}"
  }
  image_name = "${var.image_base_name}-${local.packer_build_time}"

  labels = {
    packer    = "true"
    timestamp = "${local.packer_build_time}"
  }

  machine_type = var.machine_type
  metadata = {
    enable-oslogin     = "TRUE"
    enable-oslogin-2fa = "FALSE"
  }

  network_project_id  = var.network_project_id
  omit_external_ip    = var.omit_external_ip
  project_id          = var.project_id
  source_image_family = "ubuntu-2004-lts"
  ssh_username        = "ubuntu"
  subnetwork          = var.subnetwork
  use_internal_ip     = var.use_internal_ip
  use_os_login        = true
  zone                = var.zone
}

build {
  sources = ["source.googlecompute.ubuntu-teamcity-agent"]

  provisioner "shell" {
    inline = ["timeout 60s bash -c \"while ! [ -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting on cloud-init...'; sleep 2; done\""]
  }

  provisioner "ansible" {
    ansible_env_vars = [
      "ANSIBLE_PIPELINING=yes",
      "ANSIBLE_REMOTE_TMP=/tmp/.ansible"
    ]

    extra_arguments = [
      "-e", "teamcity_base_url=${var.teamcity_base_url} teamcity_user=${var.teamcity_user}",
      "-e", "additional_configuration=${var.additional_configuration}",
      "-e", "docker_version=${var.docker_version} docker_compose_version=${var.docker_compose_version}",
      "-e", "install_stackdriver_agent=${var.install_stackdriver_agent}",
      "-e", "install_telegraf=${var.install_telegraf}",
      "-e", "ansible_python_interpreter=${var.ansible_python_interpreter}"
    ]

    playbook_file = "${path.root}/site.yml"
  }
}
