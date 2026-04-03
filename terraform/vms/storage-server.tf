resource "proxmox_vm_qemu" "storage_server" {
  name        = var.storage_server
  target_node = var.proxmox_node
  vmid       = 9010

  clone = var.vm_template

  cores  = 2
  memory = 2048

  network {
    bridge = var.network_bridge
    model  = "virtio"
  }

  disk {
    slot    = "scsi1"
    size    = "100G"
    storage = var.storage_pool
  }

  ipconfig0 = "ip=dhcp"
  sshkeys = var.ssh_public_key_homelab
}
