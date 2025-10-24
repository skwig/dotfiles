{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-24.url = "github:nixos/nixpkgs?ref=3404205";
    pr-freelens.url = "github:skwig/nixpkgs?ref=init-freelens";
    pr-qemu.url = "github:skwig/nixpkgs?ref=fps-patch-qemu";
    # pr-qemu.url = "github:skwig/nixpkgs?ref=native-qemu";

    home-manager.url = "github:nix-community/home-manager?ref=release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-24,
      pr-freelens,
      pr-qemu,
      home-manager,
      ...
    }@attrs:
    let
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
          qemu_kvm = (import pr-qemu { inherit system; }).qemu_kvm;
        };
      };
    in
    {
      nixosConfigurations = {
        blackbox = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = specialArgs // {
            username = "skwig";
            hostname = "blackbox";
          };
          modules = [
            ./hosts/blackbox/configuration.nix
            home-manager.nixosModules.default
          ];
        };

        smallbox = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = specialArgs // {
            username = "skwig";
            hostname = "smallbox";
          };
          modules = [
            ./hosts/smallbox/configuration.nix
            home-manager.nixosModules.default
          ];
        };

        vmbox = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = specialArgs // {
            username = "skwig";
            hostname = "nixos";
          };
          modules = [
            ./hosts/vmbox/configuration.nix
            home-manager.nixosModules.default
          ];
        };
      };

      nixosModules = {
        bluetooth = import ./modules/bluetooth.nix;
        desktop = import ./modules/desktop.nix;
        dev-ai = import ./modules/dev-ai.nix;
        dev-az = import ./modules/dev-az.nix;
        dev-dotnet = import ./modules/dev-dotnet.nix;
        dev-embedded = import ./modules/dev-embedded.nix;
        dev-go = import ./modules/dev-go.nix;
        dev-k8s = import ./modules/dev-k8s.nix;
        dev = import ./modules/dev.nix;
        gnome = import ./modules/gnome.nix;
        hyprland = import ./modules/hyprland.nix;
        kde = import ./modules/kde.nix;
        nvidia = import ./modules/nvidia.nix;
        personal = import ./modules/personal.nix;
        system = import ./modules/system.nix;
      };
    };
}
