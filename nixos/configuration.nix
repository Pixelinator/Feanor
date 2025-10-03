{ config, pkgs, ... }:
{
  networking.hostName = "feanor";

  environment.systemPackages = with pkgs; [ kubectl helm git jq headscale postgresql ];

  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = [ "--disable=servicelb" "--disable=traefik" "--write-kubeconfig-mode=0644" ];

  # HeadScale
  services.headscale.enable = true;
  services.headscale.listenAddr = "0.0.0.0:8080";
  services.headscale.dbType = "postgresql";
  services.headscale.dbHost = "127.0.0.1";
  services.headscale.dbPort = 5432;
  services.headscale.dbUser = "headscale";
  services.headscale.dbPassword = "headscalepassword";
  services.headscale.dbName = "headscale";
  services.headscale.privateKeyFile = "/var/lib/headscale/private.key";
  services.headscale.autoMigrate = true;

  networking.firewall.allowedTCPPorts = [ 22 8080 5432 ];

  # PostgreSQL
  services.postgresql.enable = true;
  services.postgresql.ensureDatabases = [ "headscale" "forgejo" ];
  services.postgresql.ensureUsers = [
    { name = "headscale"; password = "headscalepassword"; superuser = false; },
    { name = "forgejo"; password = "forgejopassword"; superuser = false; }
  ];

  # Daily Backup for PostgreSQL
  systemd.timers.postgresqlBackup = {
    description = "Daily Backup for HeadScale- and Forgejo-DB";
    timerConfig = {
      OnCalendar = "daily";
    };
    serviceConfig = {
      ExecStart = "pg_dump -U headscale headscale > /var/lib/headscale/backups/headscale_$(date +\%F).sql && pg_dump -U forgejo forgejo > /var/lib/headscale/backups/forgejo_$(date +\%F).sql";
    };
  };
}
