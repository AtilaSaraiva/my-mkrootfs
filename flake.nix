# This is just a direct-conversion of my non-flakes-Nix and channels to flakes
{
  description = "PedroHLC's NixOS Flake";

  # My main channel and extra repositories
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Wine with patches
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-gaming-edge = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager for managing my users' home
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Smooth-criminal bleeding-edge Mesa3D
    mesa-git-src = {
      url = "https://gitlab.freedesktop.org/mesa/mesa/-/archive/main/mesa-main.tar.gz";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@attrs: {
    # Defines a formatter for "nix fmt"
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    # My systems
    nixosConfigurations = {
      "laptop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          ./systems/core-configuration.nix
          ./systems/seat-configuration.nix
          ./systems/laptop/hardware-configuration.nix
          ./systems/laptop/configuration.nix
          # home-manager
          home-manager.nixosModules.home-manager
          {
            home-manager.users.pedrohlc = (import ./home-manager/pedrohlc.nix {
              battery = "BAT0";
              cpuSensor = "coretemp-isa-0000";
              displayBrightness = true;
              gitKey = "F5BFC029DA9A28CE";
              nvidiaPrime = true;
              touchpad = "2362:597:UNIW0001:00_093A:0255_Touchpad";
            });
          }
        ];
      };

      "desktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          ./shared/lib/graphics-stack-bleeding.nix
          ./systems/core-configuration.nix
          ./systems/seat-configuration.nix
          ./systems/desktop/hardware-configuration.nix
          ./systems/desktop/configuration.nix
          # home-manager
          home-manager.nixosModules.home-manager
          {
            home-manager.users.pedrohlc = (import ./home-manager/pedrohlc.nix {
              cpuSensor = "k10temp-pci-00c3";
              dangerousAlone = false;
              gitKey = "DF4C6898CBDC6DF5";
              gpuSensor = "amdgpu-pci-0900";
            });
          }
        ];
      };

      "vps-lab" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = attrs;
        modules = [
          (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
          ./shared/lib/oci-options.nix
          ./shared/lib/oci-common.nix
          ./systems/core-configuration.nix
          ./systems/vps-lab/configuration.nix
          ./systems/vps-lab/servers/adguard.nix
          ./systems/vps-lab/servers/nginx.nix
          ./systems/vps-lab/servers/wireguard.nix
          # home-manager
          home-manager.nixosModules.home-manager
          {
            home-manager.users.pedrohlc = (import ./home-manager/pedrohlc.nix {
              seat = false;
            });
          }
        ];
      };

    };
  };
}

