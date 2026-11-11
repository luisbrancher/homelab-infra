resource "proxmox_virtual_environment_container" "forgejo" {
  unprivileged = true
  description  = "Managed by Terraform."
  node_name    = var.proxmox_node
  vm_id        = 121

  initialization {
    hostname = var.forgejo_server

    ip_config {
      ipv4 {
        address = var.forgejo_ip
        gateway = var.network_gateway
      }
    }

    user_account {
      keys = [var.ssh_public_key]
    }
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 1024
  }

  disk {
    datastore_id = var.storage_pool
    size         = 20
  }

  network_interface {
    name   = "eth0"
    bridge = var.network_bridge
    # IP é estático (forgejo_ip), mas o MAC fica fixo para bater com a reserva no OPNsense
    # (homelab-network, setup_opnsense.yml)
    mac_address = "BC:24:11:21:68:AC"
  }

  operating_system {
    template_file_id = var.lxc_template
    type             = "debian"
  }

  features {
    # O Proxmox avisa "Systemd 257 detected. You may need to enable nesting" em LXC Debian 13.
    # Mudar features pela API exige root@pam (403 com o token do Terraform): aplicar antes no host
    # com `pct set 121 -features nesting=1` e só depois deixar este bloco no código (sem diff no plan).
    nesting = true
  }

  # Bind mount do NFS dos dumps (mp0). Criar ou mudar bind mount pela API exige root@pam, então ele é
  # aplicado à mão no host (passo 2 abaixo) e fica aqui igual ao estado real, sem diff no plan.
  # Sem este bloco, o plan vê o mp0 como drift e força destroy/recreate da LXC.
  mount_point {
    volume = "/mnt/truenas-db-dumps/forgejo"
    path   = "/mnt/db-dumps"
  }

  # Passos manuais no host Proxmox (mesmo padrão da lxc-monitoring), depois do primeiro apply:
  #   1) TUN, para o Tailscale:
  #      echo "lxc.cgroup2.devices.allow: c 10:200 rwm" >> /etc/pve/lxc/121.conf
  #      echo "lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file" >> /etc/pve/lxc/121.conf
  #   2) Bind mount do NFS dos dumps (montar o NFS no host em /mnt/truenas-db-dumps):
  #      pct set 121 -mp0 /mnt/truenas-db-dumps/forgejo,mp=/mnt/db-dumps
  #   Depois: pct reboot 121
}
