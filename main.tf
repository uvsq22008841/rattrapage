terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "~> 2.0"
    }
    ansible = {
      version = "~> 1.3.0"
      source  = "ansible/ansible"
    }
  }
}

provider "vsphere" {
  user           = "root"
  password       = "L@uren17102000"
  vsphere_server = "192.168.1.154"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}



data "vsphere_datacenter" "datacenter" {
  name = "ha-datacenter"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = "localhost"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

variable "vm_count" {
  description = "Number of VMs to create"
  default     = 1
}

variable "vm_names" {
  description = "List of VM names"
  default     = ["vm11"]
}



variable "vm_template" {
  description = "VM template to clone"
  default     = "ubuntu_template"
}




resource "vsphere_virtual_machine" "vm" {
  count = var.vm_count
  name             =  var.vm_names[count.index]
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 2
  memory           = 2048
  guest_id         = "other4xLinux64Guest"
  scsi_type        = "lsilogic-sas"
  wait_for_guest_net_timeout= -1

  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = "/ubuntu/ubuntu-24.04-desktop-amd64.iso"
  }
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  disk {
    label = "disk0"
    size  = 10
  }
}

/*resource "ansible_playbook" "playbook" {
  playbook   = "playbook.yml"
  name       = "vm1"
  replayable = true

  extra_vars = {
    var_a = "Some variable"
    var_b = "Another variable"
  }
}*/
