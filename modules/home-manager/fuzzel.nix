{ config, unstable, ... }:

{
  home.packages = [
    unstable.fuzzel
  ];

  home.file = {
    "${config.xdg.configHome}/fuzzel" = {
      source = ../../home/.config/fuzzel;
      recursive = true;
    };
  };
}
