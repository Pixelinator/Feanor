{
  hostname     = "feanor";
  ipAddress    = "192.168.188.47";
  username     = "dominic";
  system       = "x86_64-linux";
  sshPublicKeys = [
    # Add your SSH public key here so deploy-rs can authenticate without a password.
    # Example: "ssh-ed25519 AAAA... user@host"
  ];
}
