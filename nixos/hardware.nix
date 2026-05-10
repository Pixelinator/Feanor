# Hardware-specific configuration for this machine.
# For a new machine, replace this file with the output of:
#   nixos-generate-config --no-filesystems
# then add your fileSystems entries manually.
{ config, pkgs, ... }:
{
  fileSystems."/" = {
    device = "/dev/nvme0n1p2";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
  };

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # r8125: Realtek 2.5GbE NIC driver (not yet in mainline kernel)
  boot.kernelModules = [ "r8125" "r8169" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ r8125 ];
}
