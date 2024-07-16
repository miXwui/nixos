# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../../base.nix
  ];

  _module.args.hardware.platform = "intel_i7-6700hq_and_nvidia_gtx_960m";

  # Hardware modules
  hardware_input-laptop.enable = true;
  hardware_bluetooth.enable = true;
  hardware_ssd.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ## Packages
  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
    vulkan-tools
  ];
}
