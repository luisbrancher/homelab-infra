# proxmox-infra

Infraestrutura do homelab provisionada com Terraform no Proxmox. Parte de um stack completo onde o Terraform cria as VMs, o Ansible configura o OS de cada uma, e o k3s orquestra os serviços.

## Stack completo

```
Terraform   → cria as VMs no Proxmox (CPU, RAM, disco, rede)
     ↓
Ansible     → configura o OS de cada VM (instala k3s, NFS, hardening)
     ↓
k3s         → orquestra os containers e garante o estado dos serviços
     ↓
ArgoCD      → GitOps, aplica mudanças no k3s via git push
```

## Arquitetura

```
Proxmox (i5 1345U)
├── VM: k3s-node        → serviços principais
├── VM: storage-server  → NFS, backups
└── LXC: lxc-monitoring → Prometheus + Grafana + Loki

Pi4
├── Omada Controller    → gerenciamento dos APs
└── MotionEye           → câmeras
```

### k3s-node
VM principal onde todos os serviços rodam como containers orquestrados pelo k3s. O k3s substitui o Docker Compose com modelo declarativo — você descreve o estado desejado via manifests YAML e ele garante continuamente que os serviços estão rodando, reiniciando automaticamente em caso de falha.

Serviços planejados:
- NextCloud
- Jellyfin
- Immich
- UpSnap
- Traefik (ingress controller, já incluso no k3s)
- Cert-manager

### storage-server
VM dedicada a armazenamento. Exporta volumes via NFS que o k3s-node monta para persistir dados dos serviços. Disco adicional de 100GB separado do disco do OS. Não roda serviços de aplicação.

### lxc-monitoring
Container LXC leve rodando o stack de observabilidade:
- **Prometheus** — coleta métricas de todas as VMs e serviços
- **Grafana** — dashboards de CPU, RAM, disco, latência
- **Loki** — agregação de logs de todos os serviços

### Pi4
Hardware dedicado a serviços de rede e câmeras, gerenciado via Ansible.
- **Omada Controller** — gerenciamento dos APs TP-Link (Docker, imagem ARM)
- **MotionEye** — monitoramento de câmeras (bare metal via apt)

### VPN
- **Tailscale** — instalado via Ansible no OS de todas as máquinas do homelab

Roda fora do k3s intencionalmente — sobrevive a restarts da VM principal.

## Estrutura do projeto

```
homelab-infra/
├── terraform/
    ├── main.tf             → terraform block + provider proxmox
    ├── variables.tf        → todas as variáveis centralizadas
    ├── outputs.tf          → IPs das VMs após o apply
    └── vms/
        ├── k3s-node.tf
        ├── storage-server.tf
        └── monitoring.tf
```

## Pré-requisitos

- Proxmox instalado no hardware (instalação manual via ISO)
- Template Debian 12 criado no Proxmox para clone das VMs (`vm_template`)
- Template LXC Debian 12 disponível no Proxmox (`lxc_template`)
- HCP Terraform configurado com as variáveis sensíveis
- Debian ARM instalado no Pi4
 
## Como usar

```bash
terraform init
terraform plan
terraform apply
```

Após o apply, os IPs das VMs ficam disponíveis nos outputs:

```bash
terraform output ip_k3s_server
terraform output ip_storage_server
terraform output ip_monitoring_server
```

Esses IPs são usados pelo Ansible na etapa seguinte para configurar o OS de cada VM.

## Próximos passos

- [ ] Ansible para configuração do OS das VMs + TailScale + Pi services
- [ ] Instalação e configuração do k3s via Ansible
- [ ] Configuração do NFS no storage-server
- [ ] Deploy dos serviços via manifests k8s
- [ ] GitOps com ArgoCD
