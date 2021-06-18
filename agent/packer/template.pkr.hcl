packer {
  required_version = ">= 1.7.2"
}

variable "additional_configuration" {
  type    = string
  default = ""
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
  default = "5:20.10.7~3-0~ubuntu-focal"
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
  default = "false"
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
  default = "false"
}

variable "zone" {
  type = string
}

source "googlecompute" "ubuntu-teamcity-agent" {
  disable_default_service_account = true

  disk_size         = var.disk_size
  image_description = "TeamCity agent built at {{ timestamp }}"
  image_family      = var.image_base_name
  image_labels = {
    packer    = "true"
    timestamp = "{{ timestamp }}"
  }
  image_name = "${var.image_base_name}-{{ timestamp }}"

  labels = {
    packer    = "true"
    timestamp = "{{ timestamp }}"
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
    ansible_env_vars = ["ANSIBLE_PIPELINING=yes", "ANSIBLE_REMOTE_TMP=/tmp/.ansible"]
    extra_arguments  = ["-e", "teamcity_base_url=${var.teamcity_base_url} teamcity_user=${var.teamcity_user}", "-e", "additional_configuration=${var.additional_configuration}", "-e", "docker_version=${var.docker_version} docker_compose_version=${var.docker_compose_version}", "-e", "install_stackdriver_agent=${var.install_stackdriver_agent} install_telegraf=${var.install_telegraf}", "-e", "ansible_python_interpreter=/usr/bin/python3"]
    playbook_file    = "${path.root}/site.yml"
  }
}
