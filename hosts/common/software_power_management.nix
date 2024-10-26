# For setting up power management software.

{
  config,
  pkgs,
  gProgs,
  lib,
  ...
}:
let
  # Shell scripts for udev rules
  #
  # > udev doesn’t give rules access to the same PATH as a normal user. You can
  # > use something like pkgs.writeShellScript to make an executable shell
  # > script with the right shebang in your nixos config.
  #
  # https://discourse.nixos.org/t/difficulties-with-monitor-hotplug-udev/38593/4
  #
  # Had error 127 before, fixed by referencing nix store package.
  on-battery-trigger = pkgs.writeShellScript "on-battery-trigger" ''
    ${gProgs.logger}/bin/logger "POWER_SUPPLY_ONLINE false. On battery power!"
    ${
      if config.software_ppd.enable then
        "${config.software_ppd.package}/bin/powerprofilesctl set power-saver"
      else
        ""
    }
  '';
  on-ac-trigger = pkgs.writeShellScript "on-ac-trigger" ''
    ${gProgs.logger}/bin/logger "POWER_SUPPLY_ONLINE true. On AC power!"
    ${
      if config.software_ppd.enable then
        "${config.software_ppd.package}/bin/powerprofilesctl set balanced"
      else
        ""
    }
  '';
  # Unused, but needs to exist for the `services.udev.extraRules`' commented out
  # `On low battery` section below since Nix still checks for the value
  on-low-battery-trigger = pkgs.writeShellScript "on-low-battery-trigger" ''
    level=$(${gProgs.coreutils}/bin/cat /sys/class/power_supply/BAT1/capacity)
    ${gProgs.logger}/bin/logger "Low battery level ($level%) reached!"
    dunstify -h string:x-dunst-stack-tag:low_battery "Low battery: "$level"%" -h string:desktop-entry:low_battery
  '';

in
{
  imports = [
    ./software_tlp.nix
    ./software_ppd.nix
  ];

  options.software_power_management = {
    enable = lib.mkEnableOption "enables power management software.";
    powerUtil = lib.mkOption {
      default = "tlp";
      description = ''
        `tlp` or `ppd`
      '';
    };
  };

  config = lib.mkIf config.software_power_management.enable {
    software_tlp.enable = if config.software_power_management.powerUtil == "tlp" then true else false;
    software_ppd.enable = if config.software_power_management.powerUtil == "ppd" then true else false;

    ### udev rules for switching from on battery/AC power ###
    # Seems like the Framework 13 doesn't send udev events for battery discharge
    # capacity change. Checked with `udevadm monitor --property`
    # So we are using `UPower` with `poweralertd`..
    services.udev = {
      extraRules = ''
        # Switching to battery
        SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="${on-battery-trigger}"

        # Switching to AC
        SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="${on-ac-trigger}"

        # On low battery
        # Framework 13 doesn't seem to send udev events for battery discharge capacity change.
        # Instead, I'm using `UPower` with `poweralertd`.
        # SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-9]|1[0-5]", RUN+="${on-low-battery-trigger}"
      '';
    };

    systemd.services.set-power-profile-on-boot = {
      description = "Set the power profile based on AC/battery state during boot.";
      after = [ "multi-user.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeScript "set-power-profile-on-boot" ''
          #!/run/current-system/sw/bin/bash
          if [ $(${gProgs.coreutils}/bin/cat /sys/class/power_supply/ACAD/online) -eq 1 ]; then
            ${on-ac-trigger};
          else
            ${on-battery-trigger}
          fi
        ''}";
      };
    };

    ## UPower
    services.upower = {
      enable = true;
      usePercentageForPolicy = true;
      percentageLow = 15;
      percentageCritical = 7;
      percentageAction = 5;
    };
  };
}
