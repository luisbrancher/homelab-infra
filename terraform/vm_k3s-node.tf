resource "proxmox_virtual_environment_vm" "k3s_node" {
  name      = var.k3s_server
  node_name = var.proxmox_node
  vm_id     = 100

  clone {
    vm_id = var.vm_template_id
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    interface    = "scsi0"
    size         = 50
    datastore_id = var.storage_pool
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