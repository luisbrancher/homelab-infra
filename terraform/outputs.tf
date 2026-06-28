output "ip_k3s_server" {
  description = "IP from k3s-node"
  value       = try(proxmox_virtual_environment_vm.k3s_node.ipv4_addresses[1][0], "dhcp - check proxmox UI")
}

output "ip_monitoring_server" {
  description = "IP from monitoring-server"
  value       = try(proxmox_virtual_environment_container.monitoring.initialization[0].ip_config[0].ipv4[0].address, "dhcp - check proxmox UI")
}