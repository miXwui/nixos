{ config, pkgs,
  grim, slurp, swappy,
  wl-clipboard,
... }:

{
  _module.args = {
    grim = pkgs.grim;
    slurp = pkgs.slurp;
    swappy = pkgs.swappy;
    wl-clipboard = pkgs.wl-clipboard;
  };

  home.packages = [
    grim
    slurp
    swappy
    wl-clipboard
  ];
}