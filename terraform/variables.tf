# auth variables
variable "pm_api_url" {
  description = "URL da API do Proxmox"
  type        = string
}

variable "pm_api_token_id" {
  description = "Token ID do Proxmox (ex: terraform@pve!terraform-token)"
  type        = string
}

variable "pm_api_token_secret" {
  description = "Token secret do Proxmox"
  type        = string
  sensitive   = true
}

# SSH key
variable "ssh_public_key" {
  description = "ED25519 public key for SSH access"
  type        = string
}

# VMs names
variable "monitoring_server" {
  description = "Used for tagging and naming resources"
  type        = string
  default     = "lxc-monitoring"
}

variable "k3s_server" {
  description = "Used for tagging and naming resources"
  type        = string
  default     = "k3s-node"
}

# infra variables
variable "proxmox_node" {
  description = "Nome do node Proxmox"
  type        = string
  default     = "pve"
}

variable "network_bridge" {
  description = "Bridge de rede do Proxmox"
  type        = string
  default     = "vmbr0"
}

variable "vm_template_id" {
  description = "VM ID do template base para clone"
  type        = number
  default     = 9000
}

variable "lxc_template" {
  description = "Template base para clone da LXC"
  type        = string
  default     = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
}

variable "storage_pool" {
  description = "Storage pool para discos das VMs (OS)"
  type        = string
  default     = "local-lvm"
}