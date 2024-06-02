{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
