terraform {
  required_providers {
    incus = {
      source = "lxc/incus"
    }
    talos = {
      source = "siderolabs/talos"
    }
  }
}

provider "incus" {}

locals {
  cp1_ip     = "10.82.125.10"
  worker1_ip = "10.82.125.11"
  worker2_ip = "10.82.125.12"
}

resource "incus_storage_volume" "talos_iso" {
  name        = "talos-iso"
  pool        = "default"
  source_file = "/home/bala/Téléchargements/metal-amd64.iso"
}

resource "incus_profile" "talos_node" {
  name = "talos-node"

  config = {
    "security.secureboot" = "false"
    "limits.cpu"          = "2"
    "limits.memory"       = "4GiB"
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = "default"
      size = "20GiB"
    }
  }
}

resource "incus_instance" "talos_cp1" {
  name     = "talos-cp1"
  type     = "virtual-machine"
  profiles = ["default", incus_profile.talos_node.name]

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "incusbr0"
      "ipv4.address" = local.cp1_ip
    }
  }

  device {
    name = "iso-vol"
    type = "disk"
    properties = {
      pool            = "default"
      source          = incus_storage_volume.talos_iso.name
      "boot.priority" = "10"
    }
  }
}

resource "incus_instance" "talos_worker1" {
  name     = "talos-worker1"
  type     = "virtual-machine"
  profiles = ["default", incus_profile.talos_node.name]

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "incusbr0"
      "ipv4.address" = local.worker1_ip
    }
  }

  device {
    name = "iso-vol"
    type = "disk"
    properties = {
      pool            = "default"
      source          = incus_storage_volume.talos_iso.name
      "boot.priority" = "10"
    }
  }
}

resource "incus_instance" "talos_worker2" {
  name     = "talos-worker2"
  type     = "virtual-machine"
  profiles = ["default", incus_profile.talos_node.name]

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "incusbr0"
      "ipv4.address" = local.worker2_ip
    }
  }

  device {
    name = "iso-vol"
    type = "disk"
    properties = {
      pool            = "default"
      source          = incus_storage_volume.talos_iso.name
      "boot.priority" = "10"
    }
  }
}