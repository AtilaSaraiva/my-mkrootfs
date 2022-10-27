# This is just a direct-conversion of my non-flakes-Nix and channels to flakes
{
  description = "PedroHLC's NixOS Flake";

  # My main channel and extra repositories
  inputs = {
    nixpkgs.url = "github:PedroHLC/nixpkgs/contingency-channel"; #"github:NixOS/nixpkgs/nixpkgs-unstable";

    # Wine with patches
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-gaming-edge = {
      follows = "nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager for managing my users' home
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Smooth-criminal bleeding-edge Mesa3D
    mesa-git-src = {
      url = "github:Mesa3D/mesa/main";
      flake = false;
    };

    # My FFx userChrome.css
    pedrochrome-css = {
      url = "git+https://gist.github.com/3c52f40134eeadf689d6269f271c755b.git";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, ... }@attrs:
    let
      ssot = import ./shared/ssot.nix attrs;
      specialArgs = {
        inherit ssot;
        inherit (attrs) nixpkgs nix-gaming nix-gaming-edge mesa-git-src pedrochrome-css;
      };
    in
    {
      # Defines a formatter for "nix fmt"
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      # My systems
      nixosConfigurations = {
        "${ssot.vpn.laptop.hostname}" = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "x86_64-linux";
          modules = [
            ./shared/lib/wireguard-client.nix
            ./systems/core-configuration.nix
            ./systems/seat-configuration.nix
            ./systems/laptop/hardware-configuration.nix
            ./systems/laptop/configuration.nix
            # home-manager
            home-manager.nixosModules.home-manager
            {
              home-manager.users.pedrohlc = import ./home-manager/pedrohlc.nix {
                battery = "BAT0";
                cpuSensor = "coretemp-isa-0000";
                displayBrightness = true;
                gitKey = "F5BFC029DA9A28CE";
                nvidiaPrime = true;
                touchpad = "2362:597:UNIW0001:00_093A:0255_Touchpad";
              };
            }
          ];
        };

        "${ssot.vpn.desktop.hostname}" = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "x86_64-linux";
          modules = [
            ./shared/lib/graphics-stack-bleeding.nix
            ./shared/lib/journal-upload.nix
            ./shared/lib/wireguard-client.nix
            ./systems/core-configuration.nix
            ./systems/seat-configuration.nix
            ./systems/desktop/hardware-configuration.nix
            ./systems/desktop/configuration.nix
            # home-manager
            home-manager.nixosModules.home-manager
            {
              home-manager.users.pedrohlc = import ./home-manager/pedrohlc.nix {
                cpuSensor = "k10temp-pci-00c3";
                dangerousAlone = false;
                gitKey = "DF4C6898CBDC6DF5";
                gpuSensor = "amdgpu-pci-0900";
              };
            }
          ];
        };

        "${ssot.vpn.lab.hostname}" = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "aarch64-linux";
          modules = [
            (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
            ./shared/lib/oci-options.nix
            ./shared/lib/oci-common.nix
            ./systems/core-configuration.nix
            ./systems/vps-lab/configuration.nix
            ./systems/vps-lab/servers/adguard.nix
            ./systems/vps-lab/servers/journal-remote.nix
            ./systems/vps-lab/servers/nginx.nix
            ./systems/vps-lab/servers/wireguard.nix
            # home-manager
            home-manager.nixosModules.home-manager
            {
              home-manager.users.pedrohlc = import ./home-manager/pedrohlc.nix {
                seat = false;
              };
            }
          ];
        };

      };
    };
}

