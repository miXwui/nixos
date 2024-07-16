# For systems with SSD(s).

{ config, lib, ... }:

{
  options = {
    hardware_ssd.enable = lib.mkEnableOption "enables config for SSDs.";
  };

  config = lib.mkIf config.hardware_ssd.enable {
    # `nixos-hardware/common/pc/laptop/ssd`
    # https://github.com/NixOS/nixos-hardware/blob/master/common/pc/ssd/default.nix

    # fstrim every Saturday (time is not specified, for now).
    services.fstrim = {
      enable = true;
      interval = "Sat";
    };
  };
}
