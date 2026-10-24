resource "proxmox_virtual_environment_vm" "k3s_node" {
  name      = var.k3s_server
  node_name = var.proxmox_node
  vm_id     = 100

  clone {
    vm_id = var.vm_template_id
  }

  cpu {
    cores = 16
    type  = "host"
  }

  memory {
    dedicated = 16384
  }

  disk {
    interface    = "scsi0"
    size         = 50
    datastore_id = var.storage_pool
  }

  disk {
    interface    = "scsi1"
    size         = 220
    datastore_id = "media-ssd"
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