# Enable Bluetooth.

{ config, lib, ... }:

{
  options = {
    hardware_bluetooth.enable = lib.mkEnableOption "enables config for Bluetooth.";
  };

  config = lib.mkIf config.hardware_bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = true;
  };
}
