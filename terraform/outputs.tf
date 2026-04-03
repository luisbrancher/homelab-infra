output "ip_storage_server" {
  description = "Endereço IP do ${var.storage_server}"
  value       = proxmox_vm_qemu.storage_server.default_ipv4_address
}

output "ip_k3s_server" {
  description = "Endereço IP do ${var.k3s_server}"
  value       = proxmox_vm_qemu.k3s_node.default_ipv4_address
}

output "ip_monitoring_server" {
  description = "Endereço IP do ${var.monitoring_server}"
  value       = proxmox_lxc.monitoring.network[0].ip
}
