{
  pkgs,
  config,
  gcolor3,
  ...
}:

{
  _module.args = {
    gcolor3 = pkgs.gcolor3;
  };

  home.packages = [
    gcolor3
  ];

  home.file = {
    "${config.xdg.configHome}/gcolor3" = {
      source = ../../home/.config/gcolor3;
      recursive = true;
    };
  };
}
