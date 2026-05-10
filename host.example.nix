# Copy this file to host.nix and fill in your values.
# This is the only file you need to edit to adapt this repo to your machine.
{
  # The hostname for your machine. Also becomes the NixOS flake attribute name
  # and the ArgoCD node name.
  hostname = "yourhost";

  # The IP address deploy-rs will SSH to when deploying.
  ipAddress = "192.168.1.100";

  # The Linux user that will be created on the machine. Must be in the wheel group
  # (already set) so that deploy-rs can activate the system profile via sudo.
  username = "youruser";

  # The CPU architecture of your machine. Common values:
  #   "x86_64-linux"   — standard 64-bit Intel/AMD
  #   "aarch64-linux"  — ARM64 (e.g. Raspberry Pi 4/5, Apple Silicon VM)
  system = "x86_64-linux";

  # One or more SSH public keys for your user. deploy-rs uses these to
  # authenticate without a password. Get yours with: cat ~/.ssh/id_ed25519.pub
  sshPublicKeys = [
    # "ssh-ed25519 AAAA... user@host"
  ];
}
