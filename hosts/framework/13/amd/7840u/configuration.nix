# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../../../base.nix
  ];

  _module.args.hardware.platform = "amd_7840u";

  # Hardware modules
  hardware_input-laptop.enable = true;
  hardware_fingerprint.enable = true;
  hardware_bluetooth.enable = true;
  hardware_ssd.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # https://github.com/NixOS/nixos-hardware/blob/master/framework/13-inch/7040-amd/default.nix

  ### `../common` https://github.com/NixOS/nixos-hardware/blob/master/framework/13-inch/common/default.nix

  ### Needed for desktop environments to detect/manage display brightness
  hardware.sensor.iio.enable = true;

  ### `../common/amd.nix` https://github.com/NixOS/nixos-hardware/blob/master/framework/13-inch/common/amd.nix
  ### https://github.com/NixOS/nixos-hardware/blob/master/framework/13-inch/common/amd.nix

  ##### `../../../common/cpu/amd` https://github.com/NixOS/nixos-hardware/blob/master/common/cpu/amd/default.nix
  hardware.cpu.amd.updateMicrocode = true;
  # Though apparently the microcode only gets updated through AGESA through BIOS updates:
  # https://discourse.nixos.org/t/amd-microcode-updates-not-applying/31923/5
  # So it seems that it won't be updated through this.

  ##### `../../../common/cpu/amd/pstate.nix` https://github.com/NixOS/nixos-hardware/blob/master/common/cpu/amd/pstate.nix
  ##### Set amd_pstate to active for kernel > 6.3, though it's enabled by default from 6.5.
  boot.kernelParams = [ "amd_pstate=active" ];

  ##### `../../../common/gpu/amd` https://github.com/NixOS/nixos-hardware/blob/master/common/gpu/amd/default.nix
  services.xserver.videoDrivers = [ "modesetting" ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.opengl.extraPackages = with pkgs; [
    mesa
    libva
    rocmPackages.clr
    rocmPackages.clr.icd
  ];

  ## Packages
  environment.systemPackages = with pkgs; [
    amdgpu_top
    nvtopPackages.amd
    vulkan-tools
  ];
}
