# auth variables
variable "proxmox_api_url" {
  description = "URL do Proxmox"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox user"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox Password"
  type        = string
  sensitive   = true
}

# VMs names
variable "storage_server" {
  description = "Used for tagging and naming resources"
  type        = string
  default     = "storage-server"
}

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

# SSH key
variable "ssh_public_key_homelab" {
  description = "ED25519 public key for SSH access"
  type        = string
}

# infra variables
# ---------------
# qual node do Proxmox criar a VM = pve
variable "proxmox_node" {
  description = "Nome do node Proxmox"
  type        = string
  default     = "pve"
}

# qual interface de rede usar (vmbr0 é o padrão do Proxmox)
variable "network_bridge" {
  description = "Bridge de rede do Proxmox"
  type        = string
  default     = "vmbr0"
}

# qual imagem base clonar pra criar a VM
variable "vm_template" {
  description = "Template base para clone das VMs"
  type        = string
}

# qual imagem base clonar pra criar a LXC
variable "lxc_template" {
  description = "Template base para clone da LXC"
  type        = string
}

# onde guardar os discos das VMs
variable "storage_pool" {
  description = "Storage pool do Proxmox para os discos"
  type        = string
  default     = "local-lvm"
}