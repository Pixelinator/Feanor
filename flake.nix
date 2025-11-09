{
  description = "Feanor Homeserver";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs } @inputs: {
    nixosConfigurations.feanor = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./nixos/configuration.nix
        ./nixos/power-saving.nix
      ];
    };
  };
}
