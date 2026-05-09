# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A GitOps-managed homelab running on a single NixOS node (`feanor`, `192.168.188.47`). The NixOS layer installs and configures k3s; ArgoCD runs inside k3s and manages all applications by watching this Git repository.

## Key Commands

```bash
# Apply NixOS system configuration
sudo nixos-rebuild switch --flake .#

# Interact with the cluster (k3s wraps kubectl)
sudo k3s kubectl get nodes
sudo k3s kubectl get applications -n argocd

# Force ArgoCD to re-sync an app
argocd app sync <app-name>

# Create a Sealed Secret (for committing encrypted secrets)
kubeseal --format yaml < secret.yaml > sealed-secret.yaml
```

## Architecture

**Two layers, one repo:**

1. **`nixos/`** — NixOS flake (`flake.nix` + `nixos/configuration.nix`). Declares the base OS: bootloader, networking, firewall, the `dominic` user, and `services.k3s`. Pinned to nixpkgs `nixos-25.05`.

2. **`gitops/`** — Everything that runs *inside* k3s. ArgoCD is bootstrapped manually once; after that it manages itself and all apps via `root-app-of-apps.yaml`.

**GitOps flow:** `root-app-of-apps.yaml` is an `ApplicationSet` that discovers every directory under `gitops/apps/*` and creates one ArgoCD `Application` per directory. Each app gets its own namespace (named after the directory). AutoSync with pruning and self-heal is enabled globally.

**App types — two patterns in use:**

- **Helm wrapper** (`Chart.yaml` + `values.yaml`, optional `templates/`): Used by most apps (authentik, cert-manager, forgejo, forgejo-runner, jellyfin, paperless-ngx, postgres-operator). `Chart.yaml` declares the upstream chart as a dependency; `values.yaml` overrides it; extra Kubernetes manifests live in `templates/`.
- **Plain YAML** (`glance.yaml`): All-in-one manifest file with Namespace, ConfigMap, Deployment, Service, and Ingress. Used when there's no suitable upstream Helm chart.

**Ingress & TLS:** Traefik (bundled with k3s) handles ingress. cert-manager issues Let's Encrypt certs. All public services are under `*.eldamar.dev`. Annotations on Ingress resources reference `letsencrypt-production` ClusterIssuer. Porkbun API credentials for DNS-01 challenges are stored as a SealedSecret in `gitops/apps/cert-manager/templates/03-porkbun-sealed-secret.yaml`.

**Secrets:** Use `kubeseal` to encrypt secrets before committing. Never commit plain Kubernetes `Secret` manifests.

## Security Rule

**This repository is public.** Never put passwords, tokens, API keys, or any other secrets in plain text anywhere in this repo — not in `values.yaml`, not in manifests, not in comments. All secrets must be encrypted with `kubeseal` and committed as `SealedSecret` resources. Reference them in `values.yaml` via `secretKeyRef`.

## Adding a New Application

1. Create `gitops/apps/<app-name>/` — the directory name becomes the ArgoCD app name and the k8s namespace.
2. Choose a pattern:
   - **Helm wrapper:** add `Chart.yaml` (with upstream dependency) + `values.yaml`. Run `helm dependency update` locally to generate `Chart.lock` if needed.
   - **Plain YAML:** single manifest file with all resources.
3. If the app needs a database, look at how `authentik` uses `postgres-operator` (`gitops/apps/authentik/templates/01.database.yaml`) as a reference.
4. Commit and push — ArgoCD will detect the new directory and deploy automatically.
