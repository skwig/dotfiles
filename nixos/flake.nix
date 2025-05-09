{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=3404205"; # 24.11 as of 2025-03-23
    pr-freelens.url = "github:skwig/nixpkgs?ref=init-freelens";
  };

  outputs =
    {
      self,
      nixpkgs,
      pr-freelens,
      ...
    }@attrs:
    {
      nixosConfigurations.blackbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs // {
          pr-pkgs = {
            freelens = (import pr-freelens { system = "x86_64-linux"; }).freelens;
          };
          username = "skwig";
          hostname = "blackbox";
        };
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
        specialArgs = attrs // {
          pr-pkgs = {
            freelens = (import pr-freelens { system = "x86_64-linux"; }).freelens;
          };
          username = "mbr";
          hostname = "blackbox2";
        };
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
        specialArgs = attrs // {
          pr-pkgs = {
            freelens = (import pr-freelens { system = "x86_64-linux"; }).freelens;
          };
          username = "skwig";
          hostname = "smallbox";
        };
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
