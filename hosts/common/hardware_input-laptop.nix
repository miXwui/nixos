# For laptop trackpad and keyboard.
#
# Internal keyboard is remapped with `keyd`.
#
# `systemctl stop keyd` will stop the `keyd` service and disable the
# internal keyboard from working. Useful when putting an external
# keyboard over it to prevent accidental keypresses.

{ config, lib, ... }:

let
  keydConfig = builtins.readFile ../../etc/keyd/default.conf;
in
{
  options = {
    hardware_input-laptop.enable = lib.mkEnableOption "enables config for laptop trackpad and keyboard.";
  };

  config = lib.mkIf config.hardware_input-laptop.enable {
    ### libinput ###
    services.libinput = {
      enable = true;
    };

    ### keyd ###
    services.keyd.enable = true;

    # config file
    environment = {
      etc."keyd/default.conf".text = keydConfig;
    };

    ### udev rules ###
    services.udev = {
      extraRules = ''
        # Disable internal laptop keyboard. keyd can still intercept and enable the keyboard and mappings when the service is enabled.
        # When keyd is disabled, the keyboard is disabled from libinput and doesn't work since nothing is intercepting it.
        ACTION!="remove", KERNELS=="input[0-9]*", SUBSYSTEMS=="input", ATTRS{id/product}=="0001", ATTRS{id/vendor}=="0001", ATTRS{id/version}=="ab83", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      '';
    };
  };
}
