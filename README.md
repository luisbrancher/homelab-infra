## homelab-infra

Homelab infrastructure as code: Proxmox VMs provisioned with Terraform, configured with Ansible, services orchestrated with k3s and deployed via ArgoCD.

## Full stack

```
Terraform   → provisions VMs on Proxmox (CPU, RAM, disk, network)
     ↓
Ansible     → configures each VM OS (installs k3s, NFS, hardening)
     ↓
k3s         → orchestrates containers and ensures desired service state
     ↓
ArgoCD      → GitOps, applies changes to k3s via git push
```

## Architecture

```
N150
└── OPNsense bare metal → router, firewall, VLANs

Proxmox (i5 1345U)
├── VM: k3s-node        → 8 cores, 16GB RAM, 50GB + 220GB (media-ssd) disk — main services
└── LXC: lxc-monitoring → Prometheus + Grafana + Loki

NAS (TrueNAS)
└── Lenovo V50s (i3-10100) → dedicated storage, NFS shares

Pi4
├── Omada Controller    → AP management (docker)
├── MotionEye           → cameras
└── UpSnap              → Wake-on-LAN
```

### k3s-node
Main VM where all services run as containers orchestrated by k3s (8 cores, 16GB RAM). k3s replaces Docker Compose with a declarative model — you describe the desired state via YAML manifests and k3s continuously ensures services are running, automatically restarting them on failure.

Disks:
- 50GB — OS + local-path storage class (CNPG databases)
- 220GB (`media-ssd`, dedicated SSD, LVM-Thin) — Jellyfin media, mounted at `/mnt/media-ssd`

Deployed services:
- Nextcloud
- Immich
- Jellyfin
- cert-manager
- cnpg-operator
- Traefik (ingress controller, bundled with k3s)

### NAS (TrueNAS)
Dedicated hardware (Lenovo V50s, i3-10100) running TrueNAS 25.10. Replaces the old `storage-server` VM. ZFS pools: `data-ssd`, `backup-hdd`. Exports NFS shares consumed by k3s-node for persistent service data. Tailscale configured via TrueNAS Apps UI.

### lxc-monitoring
Lightweight LXC container running the observability stack:
- **Prometheus** — collects metrics from all VMs and services
- **Grafana** — dashboards for CPU, RAM, disk, latency
- **Loki** — log aggregation from all services

Runs outside k3s intentionally — survives restarts of the main VM.

### Pi4
Dedicated hardware for network and camera services, managed via Ansible.
- **Omada Controller** — TP-Link AP management (Docker, mbentley/omada-controller)
- **MotionEye** — camera monitoring (bare metal via pip)
- **UpSnap** — Wake-on-LAN (bare metal, NFS-backed data on NAS)

### VPN
- **Tailscale** — installed via Ansible on the OS of every homelab machine, and via TrueNAS Apps on the NAS

## Project structure

```
homelab-infra/
├── terraform/
│   ├── main.tf                   → terraform block + proxmox provider
│   ├── variables.tf              → all variables centralized
│   ├── outputs.tf                → VM IPs after apply 
│   ├── vm_k3s-node.tf
│   └── lxc_monitoring.tf
└── ansible/
    ├── ansible.cfg               → Ansible configuration
    ├── inventory.ini             → hosts and groups
    ├── requirements.yml          → external collections (community.general, ansible.posix)
    ├── site.yml                  → main entrypoint, imports all playbooks
    ├── group_vars/all/
    │   ├── vars.yml              → shared variables
    │   └── vault.yml             → encrypted secrets (Ansible Vault)
    └── playbooks/
        ├── proxmox.yml           → imports all Proxmox playbooks
        ├── k3s-node.yml          → k3s + media SSD + Tailscale + Node Exporter
        ├── monitoring.yml        → Prometheus + Grafana + Loki + Tailscale
        ├── pi4.yml               → Omada + MotionEye + Tailscale + Node Exporter
        └── templates/
             ├── omada-compose.yml.j2  → Omada docker-compose
             ├── prometheus.yml.j2     → Prometheus scrape config
             ├── grafana.ini.j2        → Grafana config
             ├── loki-config.j2        → Loki config
             ├── loki.service.j2       → Loki systemd service
             └── upsnap.service.j2     → UpSnap systemd service
```

## Prerequisites

- Proxmox installed on hardware (manual install via ISO)
- Debian 13 VM template created on Proxmox (`vm_template`)
- Debian 13 LXC template available on Proxmox (`lxc_template`)
- TrueNAS installed on dedicated NAS hardware, with NFS shares and Tailscale configured
- HCP Terraform configured with sensitive variables
- Raspberry Pi OS (Debian 13) installed on Pi4

## Usage

1. Provision infrastructure with Terraform

```bash
terraform init
terraform plan
terraform apply
```

After apply, VM IPs are available via outputs:

```bash
terraform output ip_k3s_server
terraform output ip_monitoring_server
```

2. Configure VMs with Ansible
Update ansible/inventory.ini with the IPs from Terraform outputs, then install required collections:

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml

# run everything
ansible-playbook site.yml

# or run specific targets
ansible-playbook playbooks/proxmox.yml
ansible-playbook playbooks/pi4.yml
ansible-playbook playbooks/monitoring.yml
```

Sensitive variables are managed via Ansible Vault:

```bash
ansible-vault edit group_vars/all/vault.yml
ansible-playbook site.yml --ask-vault-pass
```

## Next steps

- [x] Terraform for Proxmox VM provisioning
- [x] Ansible for VM OS configuration + Tailscale + Pi services + NFS setup
- [x] Service deployment via k3s manifests (https://github.com/luisbrancher/homelab-gitops)
- [x] GitOps with ArgoCD (https://github.com/luisbrancher/homelab-gitops)
- [x] Dedicated NAS (TrueNAS) replacing storage-server VM
- [x] Dedicated media SSD for Jellyfin