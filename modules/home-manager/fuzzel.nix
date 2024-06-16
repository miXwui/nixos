{ config, unstable, fuzzel, ... }:

{
  _module.args = {
    fuzzel = unstable.fuzzel;
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
