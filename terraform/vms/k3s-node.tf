resource "proxmox_vm_qemu" "k3s_node" {
  name        = var.k3s_server
  target_node = var.proxmox_node
  vmid       = 9000

  clone = var.vm_template

  cores   = 4       
  memory  = 8192

  network {
    bridge = var.network_bridge
    model  = "virtio"
  }

  ipconfig0 = "ip=dhcp"
  sshkeys = var.ssh_public_key_homelab
}
