{ config, pkgs, host, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
  time.timeZone = "Europe/Berlin";

  networking.hostName = host.hostname;
  # k3s dials its embedded apiserver over IPv6 loopback ([::1]:PORT) during
  # startup and treats a refusal as fatal instead of retrying. SLAAC-assigned
  # IPv6 on this host triggers that race on every boot; nothing here uses
  # IPv6, so disabling it sidesteps the bug entirely.
  networking.enableIPv6 = false;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22    # ssh
      80    # http
      443   # https
      5432
      6443  # k3s
      8080
      9100  # prometheus node exporter
      10250 # kubernetes metrics
      30080
      30081
    ];
    allowedUDPPorts = [
      10001 # unifi discovery
    ];
  };

  users.users.${host.username} = {
    isNormalUser = true;
    extraGroups = [ "video" "wheel" ];
    openssh.authorizedKeys.keys = host.sshPublicKeys;
  };

  # Required so deploy-rs can activate the system profile without a password prompt.
  security.sudo.extraRules = [{
    users    = [ host.username ];
    commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
  }];

  services.openssh.enable = true;
  environment.systemPackages = with pkgs; [
    kubectl kubernetes-helm git jq headscale postgresql vim btop tmux starship argocd kubeseal
  ];

  programs.starship = {
    enable = true;
    settings.add_newline = true;
  };
  programs.bash.shellInit = ''
    eval "$(starship init bash)"
  '';

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  services.k3s = {
    enable = true;
    role   = "server";
    extraFlags = [
      "--bind-address=0.0.0.0"
      "--advertise-address=${host.ipAddress}"
      "--tls-san=${host.ipAddress}"
      "--tls-san=localhost"
    ];
  };

  # k3s's upstream unit disables systemd's start-limit (StartLimitIntervalSec=0),
  # so a persistent failure (e.g. a bad cert/kubeconfig) restarts forever instead
  # of giving up. That turned a stale-kubeconfig bug into a 2+ hour crash loop
  # that pinned the CPU. Cap it: 10 restarts in 10 minutes is plenty for a slow
  # boot-time race, but a genuinely broken config will now fail out in ~2
  # minutes instead of spinning indefinitely.
  systemd.services.k3s = {
    startLimitIntervalSec = 600;
    startLimitBurst = 10;
  };
}
