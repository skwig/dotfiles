{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=3404205"; # 24.11 as of 2025-03-23
    };
  };

  outputs = { self, nixpkgs, ... }@attrs: {
    nixosConfigurations.blackbox = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./hosts/blackbox/specific.nix
        ./hosts/blackbox/hardware-configuration.nix
        ./modules/system.nix
        ./modules/desktop.nix
        ./modules/user.nix
        ./modules/dev.nix
        ./modules/dev.dotnet.nix
        ./modules/dev.go.nix
      ];
    };
  };
}
