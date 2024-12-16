{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=a0f3e10";
  };

  outputs = { self, nixpkgs, ... }@attrs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./modules/configuration.nix
      ];
    };
  };
}
