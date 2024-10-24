{
  pkgs,
  grim,
  slurp,
  swappy,
  wl-clipboard,
  xdg-utils,
  ...
}:

{
  _module.args = {
    grim = pkgs.grim;
    slurp = pkgs.slurp;
    swappy = pkgs.swappy;
    wl-clipboard = pkgs.wl-clipboard;
    xdg-utils = pkgs.xdg-utils;
  };

  home.packages = [
    grim
    slurp
    swappy
    wl-clipboard
    # TODO: clipboard history
    xdg-utils
  ];
}
