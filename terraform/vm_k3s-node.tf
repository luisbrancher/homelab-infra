resource "proxmox_vm_qemu" "k3s_node" {
  name        = var.k3s_server
  target_node = var.proxmox_node
  vmid       = 100

  clone = var.vm_template

  cores   = 4       
  memory  = 8192

  disk {
    type    = "scsi"
    slot    = 0
    size    = "50G"
    storage = var.storage_pool
  }

  network {
    id     = 0
    bridge = var.network_bridge
    model  = "virtio"
  }

  ipconfig0 = "ip=dhcp"
  sshkeys = var.ssh_public_key
}
