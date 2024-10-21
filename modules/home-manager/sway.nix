{ config, sway, pkgs, ... }:
let
  ### gtklock modules
  gtklock-userinfo = pkgs.gtklock-userinfo-module;
  gtklock-powerbar = pkgs.gtklock-powerbar-module;
  gtklock-playerctl = pkgs.gtklock-playerctl-module;

  polkit_gnome = pkgs.polkit_gnome;
in
{
  ### PACKAGES
  home.packages = with pkgs; [
    sway.pkg
    unstable.waybar

    # Lock programs
    swaylock
    gtklock
    gtklock-userinfo
    gtklock-powerbar
    gtklock-playerctl
    hyprlock

    swayidle
    wlogout

    # Polkit
    polkit_gnome
  ];

  ### SERVICES
  services.gammastep = {
    # Still testing if this is a battery drain.
    enable = false;
    provider = "geoclue2";
  };

  # https://nixos.wiki/wiki/Sway#Systemd_services
  # https://nixos.wiki/wiki/Polkit#Authentication_agents
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      PartOf = [ "graphical-session-pre.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session-pre.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  ### WRITE FILES
  home.file = {
    "${config.xdg.configHome}/sway" = {
      source = builtins.filterSource
        (path: type:
          !(
            # Exclude Sway `config` file since we need to specifically add conditionals
            (type == "regular" && baseNameOf path == "config") ||
            (type == "regular" && baseNameOf path == "config-swayfx") ||
            # Exclude so we can fill in the lock program
            (type == "regular" && baseNameOf path == "lock-screen.sh")
          )
        )
      ../../home/.config/sway;
      recursive = true;
    };

    "${config.xdg.configHome}/sway/config" = {
      text = if sway.swayfx.enable then
        builtins.readFile ../../home/.config/sway/config +
        builtins.readFile ../../home/.config/sway/config-swayfx
      else
        builtins.readFile ../../home/.config/sway/config;
    };

    # Lock screen script
    "${config.xdg.configHome}/sway/scripts/lock-screen.sh" = {
      text = builtins.replaceStrings [ "@LOCK_COMMAND@" ] [ sway.lockCommand ]
      (builtins.readFile ../../home/.config/sway/scripts/lock-screen.sh);
      executable = true;
    };

    # swaylock
    ".swaylock" = {
      source = ../../home/.swaylock;
      recursive = true;
    };

    # gtklock
    "${config.xdg.configHome}/gtklock" = {
      source = builtins.filterSource
        (path: type:
          !(
            # Exclude so we can fill in modules
            (type == "regular" && baseNameOf path == "config.ini")
          )
        )
      ../../home/.config/gtklock;
      recursive = true;
    };

    # gtklock modules
    "${config.xdg.configHome}/gtklock/config.ini" = {
      text = builtins.replaceStrings [ "@MODULES@" ] [ "${gtklock-userinfo}/lib/gtklock/userinfo-module.so;${gtklock-powerbar}/lib/gtklock/powerbar-module.so;${gtklock-playerctl}/lib/gtklock/playerctl-module.so" ]
      (builtins.readFile ../../home/.config/gtklock/config.ini);
    };

    # hyprlock
    "${config.xdg.configHome}/hypr" = {
      source = ../../home/.config/hypr;
      recursive = true;
    };

    # Wallpapers
    "${config.xdg.userDirs.extraConfig.XDG_WALLPAPERS_DIR}" = {
      source = ../../home/pictures/wallpapers;
      recursive = true;
    };

    # Waybar
    "${config.xdg.configHome}/waybar" = {
      source = ../../home/.config/waybar;
      recursive = true;
    };

    # wlogout
    "${config.xdg.configHome}/wlogout" = {
      source = ../../home/.config/wlogout;
      recursive = true;
    };
  };
}
