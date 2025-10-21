{ config, pkgs, ... }:
{
  system.stateVersion = "25.05";
  fileSystems = {
  	"/".device = "/dev/nvme0n1p2";
	"/boot" = {
	  device = "/dev/nvme0n1p1";
	  fsType = "fat32";
	};
  };

  boot = {
	loader = {
	  grub.enable = false;
	  systemd-boot.enable = true;
	};
  };

  networking.hostName = "feanor";

  environment.systemPackages = with pkgs; [ kubectl helm git jq headscale postgresql ];

  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = [ "--disable=servicelb" "--disable=traefik" "--write-kubeconfig-mode=0644" ];

  # HeadScale
  services.headscale.enable = false;
  services.headscale.settings.database.postgres.host = "127.0.0.1";
  services.headscale.settings.database.postgres.port = 5432;
  services.headscale.settings.database.postgres.user = "headscale";
  services.headscale.settings.database.postgres.password_file = "headscalepassword";
  services.headscale.settings.database.postgres.name = "headscale";

  networking.firewall.allowedTCPPorts = [ 22 8080 5432 ];

  # PostgreSQL
  services.postgresql.enable = true;
  services.postgresql.ensureDatabases = [ "headscale" "forgejo" ];
  services.postgresql.ensureUsers = [
    { name = "headscale";}
    { name = "forgejo";}
  ];

}
