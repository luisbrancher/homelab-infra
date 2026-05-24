resource "proxmox_vm_qemu" "storage_server" {
  name        = var.storage_server
  target_node = var.proxmox_node
  vmid       = 110

  clone = var.vm_template

  cores  = 2
  memory = 2048

  disk {
    type    = "scsi"
    slot    = 0
    size    = "31G"
    storage = var.storage_pool
  }

  disk {
    type    = "scsi"
    slot    = 1
    size    = "800G"
    storage = var.data_storage_pool
  }

  network {
    bridge = var.network_bridge
    model  = "virtio"
  }

  ipconfig0 = "ip=dhcp"
  sshkeys = var.ssh_public_key
}
