{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=3404205"; # 24.11 as of 2025-03-23
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    pr-freelens.url = "github:skwig/nixpkgs?ref=init-freelens";

    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    hyprpanel.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      pr-freelens,
      hyprpanel,
      ...
    }@attrs:
    {
      nixosConfigurations.blackbox = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = attrs // {
          pkgs-unstable = (
            import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            }
          );
          pkgs-pr = {
            freelens = (import pr-freelens { inherit system; }).freelens;
          };
          pkgs-hyprpanel = {
            hyprpanel = (import hyprpanel { inherit system; }).hyprpanel;
          };
          username = "skwig";
          hostname = "blackbox";
        };
        modules = [
          { nixpkgs.overlays = [ hyprpanel.overlay ]; }
          ./hosts/blackbox/configuration.nix
          ./hosts/blackbox/hardware-configuration.nix
          ./modules/system.nix
          ./modules/bluetooth.nix
          ./modules/nvidia.nix
          ./modules/hyprland.nix
          # ./modules/kde.nix
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
          pkgs-pr = {
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
          pkgs-pr = {
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
