{ config, sway, pkgs, unstable, ... }:

{
  home.packages = with pkgs; [
    sway.pkg
    unstable.waybar
    swaylock
    swayidle
    wlogout
  ];

  home.file = {
    # Write files
    "${config.xdg.configHome}/sway" = {
      # Exclude Sway `config` file since we need to specifically add conditionals.
      source = builtins.filterSource
        (path: type:
          !(
            (type == "regular" && baseNameOf path == "config") ||
            (type == "regular" && baseNameOf path == "config-swayfx")
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

    # swaylock
    ".swaylock" = {
      source = ../../home/.swaylock;
      recursive = true;
    };

    # wlogout
    "${config.xdg.configHome}/wlogout" = {
      source = ../../home/.config/wlogout;
      recursive = true;
    };
  };
}
