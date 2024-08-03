{ config, pkgs, fuzzel, ... }:

{
  _module.args = {
    fuzzel = pkgs.unstable.fuzzel;
  };

  home.packages = [
    fuzzel
  ];

  home.file = {
    "${config.xdg.configHome}/fuzzel" = {
      source = ../../home/.config/fuzzel;
      recursive = true;
    };
  };
}
