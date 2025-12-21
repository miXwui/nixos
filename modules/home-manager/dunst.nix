{
  config,
  pkgs,
  dunst,
  fuzzel,
  xdg-utils,
  ...
}:

{
  _module.args = {
    dunst = pkgs.dunst;
  };

  home.packages = [
    dunst
  ];

  home.file = {
    "${config.xdg.configHome}/dunst/dunstrc" = {
      text =
        builtins.replaceStrings
          [
            "/usr/bin/fuzzel"
            "/usr/bin/xdg-open"
          ]
          [
            "${fuzzel}/bin/fuzzel --dmenu"
            "${xdg-utils}/bin/xdg-open"
          ]
          (builtins.readFile ../../home/.config/dunst/dunstrc);
    };
  };
}
