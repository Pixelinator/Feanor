# Feanor - NixOS Homelab Setup with k3s, HeadScale, ArgoCD, Forgejo, Runner, and Ceph

This repository contains the complete setup to deploy a modern Homelab server named **Feanor** from bare metal using NixOS flakes.

## Prerequisites

- A bare-metal server (Feanor) with internet access
- USB or ISO image of NixOS 24.05
- Basic knowledge of Linux terminal

## Installation Steps

### 1. Install NixOS

1. Boot from NixOS USB or ISO
2. Partition the disks as required
3. Mount partitions (e.g., `/mnt` for root)
4. Generate NixOS configuration:
   ```bash
   nixos-generate-config --root /mnt
   ```
5. Copy this repository to `/mnt/etc/nixos/` or clone it later
6. Edit `/mnt/etc/nixos/configuration.nix` to ensure hostname is `Feanor`
7. Install NixOS:
   ```bash
   nixos-install
   ```
8. Reboot into your new system

### 2. Setup Flake-based Configuration

1. Enable experimental features if not yet enabled:
   ```bash
   mkdir -p ~/.config/nix
   echo '{ experimental-features = ["nix-command" "flakes"]; }' > ~/.config/nix/nix.conf
   ```
2. Clone this repository somewhere accessible on Feanor, e.g., `/root/homelab-flake`
3. Switch to the flake configuration:
   ```bash
   nixos-rebuild switch --flake /root/homelab-flake#homeserver
   ```

### 3. Verify Basic Services

- Check that **k3s** is running:
  ```bash
  sudo systemctl status k3s
  ```
- Ensure **HeadScale** and PostgreSQL are active:
  ```bash
  sudo systemctl status headscale
  sudo systemctl status postgresql
  ```
- Daily backups are configured automatically in `/var/lib/headscale/backups`

### 4. Deploy GitOps Applications via ArgoCD

1. Port-forward ArgoCD UI (optional):
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```
2. Apply ApplicationSet for apps-of-apps pattern:
   ```bash
   kubectl apply -f /root/homelab-flake/gitops/apps-of-apps/applicationset.yaml -n argocd
   ```

### 5. Verify Deployed Applications

- **Forgejo**: check service and web UI on port 3000
- **Forgejo Runner**: ensure runner connects to Forgejo and executes jobs
- **Ceph**: verify persistent volumes available for Kubernetes apps
- **Traefik**: acts as Ingress controller for internal/external routing
- **cert-manager**: automatically handles TLS certificates

### 6. Maintenance

- Daily backups for PostgreSQL (HeadScale and Forgejo) are stored in `/var/lib/headscale/backups`
- Add new applications to `gitops/apps/` and they will automatically be deployed via ArgoCD ApplicationSet
- Update flake dependencies by running:
  ```bash
  nix flake update
  ```

---

This setup provides a full-featured, modern Homelab environment for experimentation, GitOps workflows, and self-hosted services, fully reproducible and version-controlled via NixOS flakes.
