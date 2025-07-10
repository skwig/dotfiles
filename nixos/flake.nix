{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-24.url = "github:nixos/nixpkgs?ref=3404205";
    pr-freelens.url = "github:skwig/nixpkgs?ref=init-freelens";

    home-manager.url = "github:nix-community/home-manager?ref=release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    hyprpanel.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-24,
      pr-freelens,
      home-manager,
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
          pkgs-24 = (
            import nixpkgs-24 {
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
          home-manager.nixosModules.default
          ./hosts/blackbox/configuration.nix
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
          { nixpkgs.overlays = [ hyprpanel.overlay ]; }
          home-manager.nixosModules.default
          ./hosts/blackbox2/configuration.nix
        ];
      };

      nixosConfigurations.smallbox = nixpkgs.lib.nixosSystem rec {
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
          hostname = "smallbox";
        };
        modules = [
          { nixpkgs.overlays = [ hyprpanel.overlay ]; }
          home-manager.nixosModules.default
          ./hosts/smallbox/configuration.nix
        ];
      };
    };
}
