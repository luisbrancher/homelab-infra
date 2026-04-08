resource "proxmox_lxc" "monitoring" {
  hostname    = var.monitoring_server
  target_node = var.proxmox_node
  vmid        = 9020

  ostemplate = var.lxc_template

  cores  = 2
  memory = 1024

  network {
    name   = "eth0"
    bridge = var.network_bridge
    ip     = "dhcp"
  }

  rootfs {
    size    = "20G"
    storage = var.storage_pool
  }

  ssh_public_keys = var.ssh_public_key_homelab
}