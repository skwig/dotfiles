{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=3404205"; # 24.11 as of 2025-03-23
    };
    vgpu4nixos = {
      url = "github:mrzenc/vgpu4nixos"; # TODO: Define commit
    };
    fastapi-dls-nixos = {
      url = "github:mrzenc/fastapi-dls-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, vgpu4nixos, fastapi-dls-nixos, ... }@attrs: {
    nixosConfigurations.blackbox = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./hosts/blackbox/specific.nix
        ./hosts/blackbox/hardware-configuration.nix
        ./modules/system.nix
        # ./modules/kvmfr-options.nix
        # ./modules/desktop.nix
        ./modules/kde.nix
        ./modules/user.nix
        ./modules/dev.nix
        ./modules/dev.dotnet.nix
        ./modules/dev.go.nix
        vgpu4nixos.nixosModules.host
        fastapi-dls-nixos.nixosModules.default
      ];
    };

    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./hosts/vm/specific.nix
        ./hosts/vm/hardware-configuration.nix
        ./modules/system.nix
        ./modules/desktop.nix
        ./modules/user.nix
        vgpu4nixos.nixosModules.guest
      ];
    };
  };
}
