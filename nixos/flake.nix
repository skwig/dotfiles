{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=3404205"; # 24.11 as of 2025-03-23
    };
    pr-freelens = { url = "github:skwig/nixpkgs?ref=init-freelens"; };
  };

  outputs = { self, nixpkgs, pr-freelens, ... }@attrs:
    let
      system = "x86_64-linux";
      pkgsWithFreelens = import pr-freelens { inherit system; };
    in {
      nixosConfigurations.blackbox = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = attrs // { freelensPkg = pkgsWithFreelens.freelens; };
        modules = [
          ./hosts/blackbox/configuration.nix
          ./hosts/blackbox/hardware-configuration.nix
          ./modules/system.nix
          ./modules/bluetooth.nix
          ./modules/nvidia.nix
          ./modules/hyprland.nix
          ./modules/personal.nix
          ./modules/dev.nix
          ./modules/dev.dotnet.nix
          ./modules/dev.az.nix
          ./modules/dev.k8s.nix
          ./modules/dev.go.nix
        ];
      };

      nixosConfigurations.blackbox2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          ./hosts/blackbox2/configuration.nix
          ./hosts/blackbox2/hardware-configuration.nix
          ./modules/system.nix
          # ./modules/bluetooth.nix
          ./modules/nvidia.nix
          ./modules/hyprland.nix
          ./modules/dev.nix
          ./modules/dev.dotnet.nix
          ./modules/dev.go.nix
        ];
      };

      nixosConfigurations.smallbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          ./hosts/smallbox/configuration.nix
          ./hosts/smallbox/hardware-configuration.nix
          ./modules/system.nix
          ./modules/bluetooth.nix
          ./modules/hyprland.nix
          ./modules/personal.nix
          ./modules/dev.nix
          ./modules/dev.dotnet.nix
          ./modules/dev.az.nix
          ./modules/dev.k8s.nix
          ./modules/dev.go.nix
        ];
      };
    };
}
