{ config, pkgs, lib, ... }:

{
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };

  boot.kernelParams = [
    "amd_pstate=active"
    "idle=nomwait"
    "pcie_aspm.policy=powersupersave"
  ];

  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "schedutil";
        turbo = "auto";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    powertop
  ];

  systemd.services.powertop-tune = {
    description = "Apply powertop tunables at boot";
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.powertop}/bin/powertop --auto-tune";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
