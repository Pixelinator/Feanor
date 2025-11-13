{ config, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
  time.timeZone = "Europe/Berlin";
  fileSystems = {
  	"/".device = "/dev/nvme0n1p2";
	"/boot" = {
	  device = "/dev/nvme0n1p1";
	  fsType = "vfat";
	};
  };

  boot = {
	loader = {
		efi = {
		  efiSysMountPoint = "/boot";
		};
	  grub.enable = false;
	  systemd-boot.enable = true;
	};
	kernelModules = [ "r8125" "r8169" ];
	extraModulePackages = with config.boot.kernelPackages; [ r8125 ];
  };

  # networking
  networking.hostName = "feanor";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 # ssh
      80 # http
      443 # https
      5432
      6443 # k3s
      8080
      9100 # prometheus node exporter
      10250 # kubernetes metrics
      30080
      30081
    ];
    allowedUDPPorts = [
      10001 # unifi discovery
    ];
  };

  users.users.dominic = {
	isNormalUser = true;
	initialPassword = "pw123";
	extraGroups = [ "video" "wheel" ];
  };

  services.openssh.enable = true;
  environment.systemPackages = with pkgs; [ kubectl kubernetes-helm git jq headscale postgresql vim btop tmux starship argocd ];

  programs.starship = {
    enable = true;
    settings = {
	add_newline = true;
    };
  };
  programs.bash.shellInit = ''
      eval "$(starship init bash)"
  '';

  programs.neovim = {
	enable = true;
	defaultEditor = true;
	vimAlias = true;
  };

  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = [
    "--bind-address=0.0.0.0"
    "--advertise-address=192.168.188.47"
    "--tls-san=192.168.188.47"
    "--tls-san=localhost"
  ];

}
