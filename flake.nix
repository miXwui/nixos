{
  description = "NixOS and home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, ... }@inputs:
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
      ];
    in
    {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/default/configuration.nix
            inputs.home-manager.nixosModules.default
            { nixpkgs.overlays = overlays; }
          ];
        };
      };

      # https://github.com/nix-community/nixos-generators?tab=readme-ov-file#using-in-a-flake
      packages.x86_64-linux = {
       iso = nixos-generators.nixosGenerate {
         system = "x86_64-linux";

         specialArgs = { inherit inputs; };
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
