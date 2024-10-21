{
  description = "NixOS and home-manager configuration";

  inputs = {
    # Nix packages and unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # nixos-generators
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # sops-nix
    sops-nix = {
      url = "github:Mic92/sops-nix";
      # optional, not necessary for the module
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/emacs-overlay/issues/396#issuecomment-2071348230
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-generators,
      nixos-hardware,
      emacs-overlay,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      overlays = [
        (final: prev: {
          unstable = import inputs.nixpkgs-unstable {
            system = final.system;
            config.allowUnfree = true;
          };
        })
        emacs-overlay.overlays.default
      ];
    in
    {
      nixosConfigurations = {
        framework_13_amd_7840u = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/framework/13/amd/7840u/configuration.nix
            inputs.home-manager.nixosModules.default
            # nixos-hardware.nixosModules.framework-13-7040-amd
            { nixpkgs.overlays = overlays; }
          ];
        };

        framework_13_intel_i7-1165g7 = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/framework/13/intel/i7-1165g7/configuration.nix
            inputs.home-manager.nixosModules.default
            nixos-hardware.nixosModules.framework-11th-gen-intel
            { nixpkgs.overlays = overlays; }
          ];
        };

        dell_xps_15_9550_intel_i7-6700hq_and_nvidia_gtx-960m = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/dell/xps_15_9550/intel_i7-6700hq_and_nvidia_gtx-960m/configuration.nix
            inputs.home-manager.nixosModules.default
            # nixos-hardware.nixosModules.dell-xps-15-9550-nvidia
            nixos-hardware.nixosModules.dell-xps-15-9550
            nixos-hardware.nixosModules.common-gpu-nvidia-disable
            { nixpkgs.overlays = overlays; }
          ];
        };

        qemu = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/qemu/configuration.nix
            inputs.home-manager.nixosModules.default
            { nixpkgs.overlays = overlays; }
          ];
        };
      };

      # https://github.com/nix-community/nixos-generators?tab=readme-ov-file#using-in-a-flake
      packages.x86_64-linux = {
        iso = nixos-generators.nixosGenerate {
          system = "x86_64-linux";

          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/live-image/configuration.nix
            inputs.home-manager.nixosModules.default
            { nixpkgs.overlays = overlays; }
          ];

          format = "iso";
        };
      };
    };
}
