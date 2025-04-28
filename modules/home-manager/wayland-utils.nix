{
  pkgs,
  grim,
  slurp,
  swappy,
  wf-recorder,
  wl-clipboard,
  xdg-utils,
  ...
}:

{
  _module.args = {
    grim = pkgs.grim;
    slurp = pkgs.slurp;
    swappy = pkgs.swappy;
    wf-recorder = pkgs.wf-recorder;
    wl-clipboard = pkgs.wl-clipboard;
    xdg-utils = pkgs.xdg-utils;
  };

  home.packages = [
    grim
    slurp
    swappy
    wf-recorder
    wl-clipboard
    # TODO: clipboard history
    xdg-utils
  ];
}
