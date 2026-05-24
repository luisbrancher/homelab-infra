output "ip_storage_server" {
  description = "IP from storage-server"
  value       = proxmox_virtual_environment_vm.storage_server.ipv4_addresses[0][0]
}

output "ip_k3s_server" {
  description = "IP from k3s-node"
  value       = proxmox_virtual_environment_vm.k3s_node.ipv4_addresses[0][0]
}

output "ip_monitoring_server" {
  description = "IP from monitoring-server"
  value       = proxmox_virtual_environment_container.monitoring.initialization[0].ip_config[0].ipv4[0].address
}