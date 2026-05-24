resource "proxmox_virtual_environment_vm" "storage_server" {
  name      = var.storage_server
  node_name = var.proxmox_node
  vm_id     = 110

  clone {
    vm_id = var.vm_template_id
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  disk {
    interface    = "scsi0"
    size         = 31
    datastore_id = var.storage_pool
  }

  disk {
    interface    = "scsi1"
    size         = 800
    datastore_id = var.data_storage_pool
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      keys = [var.ssh_public_key]
    }
  }
}