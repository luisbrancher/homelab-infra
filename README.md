# proxmox-infra

Homelab infrastructure provisioned with Terraform on Proxmox. Part of a complete stack where Terraform creates the VMs, Ansible configures each OS, and k3s orchestrates the services.

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
    ├── main.tf             → terraform block + proxmox provider
    ├── variables.tf        → all variables centralized
    ├── outputs.tf          → VM IPs after apply
    └── vms/
        ├── k3s-node.tf
        ├── storage-server.tf
        └── monitoring.tf
```

## Prerequisites

- Proxmox installed on hardware (manual install via ISO)
- Debian 12 VM template created on Proxmox (`vm_template`)
- Debian 12 LXC template available on Proxmox (`lxc_template`)
- HCP Terraform configured with sensitive variables
- Debian ARM installed on Pi4

## Usage

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

These IPs are used by Ansible in the next step to configure each VM OS.

## Next steps

- [ ] Ansible for VM OS configuration + Tailscale + Pi services
- [ ] k3s installation and configuration via Ansible
- [ ] NFS setup on storage-server
- [ ] Service deployment via k8s manifests
- [ ] GitOps with ArgoCD