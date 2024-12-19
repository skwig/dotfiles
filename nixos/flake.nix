{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=a0f3e10d9435"; # 24.11 but tag is missing from github for whatever reason
  };

  outputs = { self, nixpkgs, ... }@attrs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./modules/system.nix
        ./modules/desktop.nix
        ./modules/user.nix
        ./modules/dev.nix
        ./modules/dev.dotnet.nix
        ./modules/dev.go.nix
        ./modules/hardware-configuration.nix
      ];
    };
  };
}
