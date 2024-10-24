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

  # # amdgpu video power saving patches
  # specialisation.drm-amdgpu-vcn = { inheritParentConfig = true; configuration =
  #   {
  #     boot.kernelPatches = [
  #       # https://gitlab.freedesktop.org/drm/amd/-/issues/3195#note_2485525
  #       {
  #         name = "1-identify-unified-queue";
  #         patch = (builtins.fetchurl {
  #           url = "https://git.kernel.org/pub/scm/linux/kernel/git/superm1/linux.git/patch/?id=23fddba4039916caa6a96052732044ddcf514886";
  #           sha256 = "sha256-q57T2Ko79DmJEfgKC3d+x/dY2D34wQCSieVrfWKsF5E=";
  #         });
  #       }
  #       {
  #         name = "2-not-pause-dpg";
  #         patch = (builtins.fetchurl {
  #           url = "https://git.kernel.org/pub/scm/linux/kernel/git/superm1/linux.git/patch/?id=3941fd6be7cf050225db4b699757969f8950e2ce";
  #           sha256 = "sha256-JYOLF5ZUxDx9T9jaZCvSQtowUq38qiGPsmAMlaCi5qg=";
  #         });
  #       }
  #     ];
  #   };
  # };

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

  # https://wiki.nixos.org/wiki/AMD_GPU
  # https://wiki.nixos.org/wiki/Graphics
  # https://www.reddit.com/r/NixOS/comments/1dmkim8/comment/l9zaz75/
  # > Side note: you don't need to enable amdvlk unless you have a very specific reason to. Mesa has radv by default which is better for vulkan.
  # Also apparently do not need `libvdpau-va-gl` or `libvdpau` since `amdgpu`/
  # Mesa already include support for VA-API and VDPAU...according to Perplexity.
  hardware.graphics = {
    enable = true; # Mesa is installed with this option.
    enable32Bit = true;
    # https://nixos.wiki/wiki/Accelerated_Video_Playback
    extraPackages = with pkgs; [
      libva
      rocmPackages.clr.icd
      clinfo
    ];
  };

  hardware.amdgpu.initrd.enable = true;

  ## Packages
  environment.systemPackages = with pkgs; [
    amdgpu_top
    nvtopPackages.amd
    vulkan-tools
  ];
}
