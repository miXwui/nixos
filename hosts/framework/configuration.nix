# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  fprintd = pkgs.fprintd;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ../base.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.libinput = {
    enable = true;
  };

  services.udev = {
    extraRules = ''
    # Disable internal laptop keyboard. keyd can still intercept and enable the keyboard and mappings when the service is enabled.
    # When keyd is disabled, the keyboard is disabled from libinput and doesn't work since nothing is intercepting it.
    ACTION!="remove", KERNELS=="input[0-9]*", SUBSYSTEMS=="input", ATTRS{id/product}=="0001", ATTRS{id/vendor}=="0001", ATTRS{id/version}=="ab83", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    '';
  };

  # https://github.com/NixOS/nixos-hardware/blob/master/framework/13-inch/7040-amd/default.nix

  ### `../common` https://github.com/NixOS/nixos-hardware/blob/master/framework/13-inch/common/default.nix

  ##### `../../../common/pc/laptop/ssd`
  ##### https://github.com/NixOS/nixos-hardware/blob/master/common/pc/ssd/default.nix
  services.fstrim = {
    enable = true;
    interval = "Sat";
  };

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

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  # Fingerprint + PAM
  services.fprintd = {
    enable = true;
    package = fprintd;
  };

  # Turn off fingerprint for login that's used in e.g. SDDM because
  # fingerprint can't unlock keyring currently.
  security.pam.services.login.fprintAuth = false;

  # Swaylock: enter password, or press enter on empty password field to use fingerprint
  # https://github.com/swaywm/sway/issues/2773#issuecomment-427570877
  security.pam.services.swaylock = {
    text = ''
      auth sufficient ${fprintd}/lib/security/pam_fprintd.so
      auth sufficient pam_unix.so likeauth try_first_pass
    '';
  };

  security.pam.services.gtklock = {
    text = ''
      auth sufficient pam_unix.so try_first_pass likeauth nullok
      auth sufficient ${fprintd}/lib/security/pam_fprintd.so
    '';
  };

  security.pam.services.hyprlock = {
    text = ''
      auth sufficient pam_unix.so try_first_pass likeauth nullok
      auth sufficient ${fprintd}/lib/security/pam_fprintd.so timeout=10
    '';
  };

  ## Packages
  environment.systemPackages = with pkgs; [
    amdgpu_top
    nvtopPackages.amd
    vulkan-tools
  ];

  ## SOPS
  sops = {
    secrets = {
      google_api_key  = { owner = config.main-user.username; };
      ssh_private_key = { owner = config.main-user.username; };
      ssh_public_key  = { owner = config.main-user.username; };
    };
  };
}
