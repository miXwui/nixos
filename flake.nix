{
  description = "NixOS and home-manager configuration";

  # For stable with unstable packages [1]
  # For totally unstable packages [2]

  # Useful to show `follows`: `nix flake metadata`.
  # ~~However, we're not manually setting any `follows`.
  # This is to avoid the possible headache of build conflicts, trading for
  # larger download sizes and disk space usage.~~
  #
  # Actually, this error with `sops-nix` still occurred without `follows`:
  # ```
  # error: builder for '/nix/store/a3gfziqmfsydr5mfv087y9q95r7kn0zd-manifest.json.drv' failed with exit code 127;
  #     last 1 log lines:
  #     > /build/.attr-0l2nkwhif96f51f4amnlf414lhl4rv9vh8iffyp431v6s28gsr90: line 14: /nix/store/2ay4jk44gqvwxikdhaspz4f9fhldxzgj-sops-install-secrets-0.0.1/bin/sops-install-secrets: No such file or directory
  # ```

  inputs = {
    # [1]
    # Nix packages and unstable
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # [2]
    # Switched totally to unstable (because of issues like Mesa mismatch:
    # https://github.com/NixOS/nixpkgs/issues/343806).
    # Should be reliable. If an update breaks, wait until the issue's fixed.
    #
    # > Between nixpkgs-unstable and master is about 3 days and a binary cache
    # > And then like 1-2 more days till nixos-unstable
    # `nixos-unstable` also has critical NixOS tests to lessen breaking updates.
    # https://www.reddit.com/r/NixOS/comments/1f46b04/comment/lkiww1t/
    #
    # Also see: https://status.nixos.org/

    nixpkgs.url = "nixpkgs/nixos-unstable";

    # nixos-generators
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      # url = "github:nix-community/home-manager/release-24.05"; # [1]
      url = "github:nix-community/home-manager"; # [2]
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # sops-nix
    sops-nix = {
      url = "github:Mic92/sops-nix/";
      # inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/emacs-overlay/issues/396#issuecomment-2071348230
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      overlays = [
        # # [1]
        # (final: prev: {
        #   unstable = import inputs.nixpkgs-unstable {
        #     system = final.system;
        #     config.allowUnfree = true;
        #   };
        # })
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
