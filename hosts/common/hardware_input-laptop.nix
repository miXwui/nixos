# For laptop trackpad and keyboard.
#
# Internal keyboard is remapped with `keyd`.
#
# `systemctl stop keyd` will stop the `keyd` service and disable the
# internal keyboard from working. Useful when putting an external
# keyboard over it to prevent accidental keypresses.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  keydConfig = builtins.readFile ../../etc/keyd/default.conf;

  # Lily58 bluetooth keyboard MAC address

  toggleScript = pkgs.writeShellScriptBin "toggle-internal-kb" ''
    BT_ADDR="FC:A3:7B:3A:27:4F"

    BTCTL="${pkgs.bluez}/bin/bluetoothctl"
    GREP="${pkgs.gnugrep}/bin/grep"
    SYSTEMCTL="${pkgs.systemd}/bin/systemctl"

    if $BTCTL info "$BT_ADDR" 2>/dev/null | $GREP -q "Connected: yes"; then
      $SYSTEMCTL stop keyd.service
    else
      $SYSTEMCTL start keyd.service
    fi
  '';
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
    # Run `udevadm monitor --environment --udev` to monitor udev events.
    # Run `udevadm info -a -p /devices/virtual/misc/uhid/.../input/input86/eventN`
    # to get ATTRS{}

    services.udev = {
      extraRules = ''
        # Disable internal laptop keyboard. keyd can still intercept and enable the keyboard and mappings when the service is enabled.
        # When keyd is disabled, the keyboard is disabled from libinput and doesn't work since nothing is intercepting it.
        ACTION!="remove", KERNELS=="input[0-9]*", SUBSYSTEMS=="input", ATTRS{id/product}=="0001", ATTRS{id/vendor}=="0001", ATTRS{id/version}=="ab83", ENV{LIBINPUT_IGNORE_DEVICE}="1"
        # Stop/start keyd when Lily58 bluetooth keyboard connects/disconnects.
        ACTION=="add", SUBSYSTEM=="input", ATTRS{name}=="Lily58 Keyboard", RUN+="${pkgs.systemd}/bin/systemctl stop keyd.service"
        ACTION=="remove", SUBSYSTEM=="input", ATTRS{name}=="Lily58 Keyboard", RUN+="${pkgs.systemd}/bin/systemctl start keyd.service"
        # We're using `/etc/systemd/system-sleep/keyd-toggle` and `bin/toggle-internal-kb` to stop/start between system sleep/resume.
      '';
    };

    # For all: suspend, hibernate, hybrid-sleep, suspend-then-hibernate
    environment.etc."systemd/system-sleep/keyd-toggle" = {
      mode = "0755";
      text = ''
        #!/run/current-system/sw/bin/bash
        case $1 in
          post)
            ${toggleScript}/bin/toggle-internal-kb
            ;;
        esac
      '';
    };

    ### Packages ###
    environment.systemPackages = with pkgs; [ libinput ];
  };
}
