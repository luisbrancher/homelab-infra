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
├── VM: k3s-node        → main services
├── VM: storage-server  → NFS, backups
└── LXC: lxc-monitoring → Prometheus + Grafana + Loki

Pi4
├── Omada Controller    → AP management
└── MotionEye           → cameras
```

### k3s-node
Main VM where all services run as containers orchestrated by k3s. k3s replaces Docker Compose with a declarative model — you describe the desired state via YAML manifests and k3s continuously ensures services are running, automatically restarting them on failure.

Planned services:
- Nextcloud
- Jellyfin
- Immich
- UpSnap
- Traefik (ingress controller, bundled with k3s)
- Cert-manager

### storage-server
VM dedicated to storage. Exports NFS volumes mounted by k3s-node to persist service data. Additional 100GB disk separate from the OS disk. Does not run any application services.

### lxc-monitoring
Lightweight LXC container running the observability stack:
- **Prometheus** — collects metrics from all VMs and services
- **Grafana** — dashboards for CPU, RAM, disk, latency
- **Loki** — log aggregation from all services

Runs outside k3s intentionally — survives restarts of the main VM.

### Pi4
Dedicated hardware for network and camera services, managed via Ansible.
- **Omada Controller** — TP-Link AP management (Docker, ARM image)
- **MotionEye** — camera monitoring (bare metal via apt)

### VPN
- **Tailscale** — installed via Ansible on the OS of every homelab machine

## Project structure

```
homelab-infra/
├── terraform/
│   ├── main.tf                   → terraform block + proxmox provider
│   ├── variables.tf              → all variables centralized
│   ├── outputs.tf                → VM IPs after apply
│   └── vms/
│       ├── k3s-node.tf
│       ├── storage-server.tf
│       └── monitoring.tf
└── ansible/
    ├── inventory.ini             → hosts and groups
    ├── site.yml                  → main entrypoint, imports all playbooks
    ├── group_vars/all/
    │   ├── vars.yml              → shared variables
    │   └── vault.yml             → encrypted secrets (Ansible Vault)
    └── playbooks/
        ├── proxmox.yml           → imports all Proxmox playbooks
        ├── k3s-node.yml          → k3s + Tailscale + Node Exporter
        ├── storage-server.yml    → NFS + Tailscale + Node Exporter
        ├── monitoring.yml        → Prometheus + Grafana + Loki + Tailscale
        ├── pi4.yml               → Omada + MotionEye + Tailscale + Node Exporter
        └── templates/
            ├── exports.j2        → /etc/exports (NFS)
            ├── prometheus.yml.j2 → Prometheus scrape config
            ├── grafana.ini.j2    → Grafana config
            ├── loki-config.j2    → Loki config
            └── loki.service.j2   → Loki systemd service
```

## Prerequisites

- Proxmox installed on hardware (manual install via ISO)
- Debian 12 VM template created on Proxmox (`vm_template`)
- Debian 12 LXC template available on Proxmox (`lxc_template`)
- HCP Terraform configured with sensitive variables
- Debian ARM installed on Pi4

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
terraform output ip_storage_server
terraform output ip_monitoring_server
```

2. Configure VMs with Ansible
Update ansible/inventory.ini with the IPs from Terraform outputs, then:

```bash
bashcd ansible

# run everything
ansible-playbook site.yml

# or run specific targets
ansible-playbook playbooks/proxmox.yml
ansible-playbook playbooks/pi4.yml
ansible-playbook playbooks/monitoring.yml
```

Sensitive variables are managed via Ansible Vault:

```bash
bashansible-vault edit group_vars/all/vault.yml
ansible-playbook site.yml --ask-vault-pass
```

## Next steps

- [x] Terraform for Proxmox VM provisioning
- [x] Ansible for VM OS configuration + Tailscale + Pi services + NFS setup
- [ ] Service deployment via k3s manifests
- [ ] GitOps with ArgoCD