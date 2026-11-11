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
    size         = 100
    datastore_id = var.storage_pool
    discard      = "on"
    ssd          = true
  }

  disk {
    interface    = "scsi1"
    size         = 220
    datastore_id = "media-ssd"
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
    # MAC fixo: o IP 10.10.10.11 vem da reserva DHCP no OPNsense (homelab-network, setup_opnsense.yml).
    # Sem ele, recriar a VM gera MAC novo, IP novo, e quebra inventário, PVs e DNS.
    mac_address = "BC:24:11:5A:36:6A"
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