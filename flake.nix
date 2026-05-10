{
  description = "Feanor Homeserver";

  inputs = {
    nixpkgs.url   = "github:NixOS/nixpkgs/nixos-25.05";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = { self, nixpkgs, deploy-rs, ... }:
    let
      host = import ./host.nix;
    in {
      nixosConfigurations.${host.hostname} = nixpkgs.lib.nixosSystem {
        system  = host.system;
        modules = [
          ./nixos/configuration.nix
          ./nixos/hardware.nix
          { _module.args = { inherit host; }; }
        ];
      };

      deploy.nodes.${host.hostname} = {
        hostname = host.ipAddress;
        profiles.system = {
          sshUser     = host.username;
          user        = "root";
          remoteBuild = true;
          path        = deploy-rs.lib.${host.system}.activate.nixos
                          self.nixosConfigurations.${host.hostname};
        };
      };

      # Type-checks the deploy configuration at `nix flake check` time.
      checks = builtins.mapAttrs
        (_system: deployLib: deployLib.deployChecks self.deploy)
        deploy-rs.lib;
    };
}
