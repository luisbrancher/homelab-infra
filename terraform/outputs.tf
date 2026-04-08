output "ip_storage_server" {
  description = "IP from storage-server"
  value       = proxmox_vm_qemu.storage_server.default_ipv4_address
}

output "ip_k3s_server" {
  description = "IP from k3s-node"
  value       = proxmox_vm_qemu.k3s_node.default_ipv4_address
}

output "ip_monitoring_server" {
  description = "IP from monitoring-server"
  value       = proxmox_lxc.monitoring.network[0].ip
}