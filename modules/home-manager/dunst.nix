{ config, pkgs, unstable, ... }:

{
  home.packages = with pkgs; [
    dunst
    libnotify # for notify-send
  ];

  home.file = {
    "${config.xdg.configHome}/dunst/dunstrc" = {
      text = builtins.replaceStrings
      [
        "/usr/bin/fuzzel"
        "/usr/bin/xdg-open"
      ]
      [
        "${unstable.fuzzel}/bin/fuzzel --dmenu"
        "${pkgs.xdg-utils}/bin/xdg-open"
      ]
      (builtins.readFile ../../home/.config/dunst/dunstrc);
    };
  };
}
