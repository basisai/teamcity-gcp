packer {
  required_version = ">= 1.7.2"
}

variable "admin_email" {
  type    = string
  default = "infraadmin@basis-ai.com"
}

variable "docker_compose_version" {
  type    = string
  default = "1.29.2"
}

variable "docker_version" {
  type    = string
  default = "5:20.10.7~3-0~ubuntu-focal"
}

variable "domain_name" {
  type    = string
  default = "teamcity.amoy.ai"
}

variable "image_base_name" {
  type    = string
  default = "teamcity-server"
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

variable "use_internal_ip" {
  type    = string
  default = "false"
}

variable "zone" {
  type = string
}

source "googlecompute" "ubuntu-teamcity-server" {
  disable_default_service_account = true

  image_description = "TeamCity Server built at {{ timestamp }}"
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
  sources = ["source.googlecompute.ubuntu-teamcity-server"]

  provisioner "shell" {
    inline = ["timeout 60s bash -c \"while ! [ -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting on cloud-init...'; sleep 2; done\""]
  }

  provisioner "ansible" {
    extra_arguments = ["-e", "docker_version=${var.docker_version} docker_compose_version=${var.docker_compose_version} admin_email=${var.admin_email} domain_name=${var.domain_name}", "-e", "ansible_python_interpreter=/usr/bin/python3"]
    playbook_file   = "${path.root}/site.yml"
  }
}
