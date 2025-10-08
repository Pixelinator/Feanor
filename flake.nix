{
  description = "NixOS + k3s + HeadScale + GitOps + Forgejo + Runner + Ceph";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05",
    deploy-rs.url = "github:serokell/deploy-rs"
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.homeserver = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./nixos/configuration.nix ];
    };

    deploy.nodes.some-random-system = {
        hostname = "homeserver";
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.homeserver;
        };
    };

    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}

