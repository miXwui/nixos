{ config, sway, pkgs, unstable, ... }:
let
  ### gtklock modules
  gtklock-userinfo = pkgs.gtklock-userinfo-module;
  gtklock-powerbar = pkgs.gtklock-powerbar-module;
  gtklock-playerctl = pkgs.gtklock-playerctl-module;
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
  ];

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
    "Pictures/Wallpapers" = {
      source = ../../home/Pictures/Wallpapers;
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
