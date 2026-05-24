resource "proxmox_virtual_environment_container" "monitoring" {
  description = "Managed by Terraform."
  node_name   = var.proxmox_node
  vm_id       = 120

  initialization {
    hostname = var.monitoring_server

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [var.ssh_public_key]
    }
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 1024
  }

  disk {
    datastore_id = var.storage_pool
    size         = 20
  }

  network_interface {
    name   = "eth0"
    bridge = var.network_bridge
  }

  operating_system {
    template_file_id = var.lxc_template
    type             = "debian"
  }
}