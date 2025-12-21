{
  pkgs,
  grim,
  slurp,
  swappy,
  wf-recorder,
  wl-clipboard,
  xdg-utils,

  wl-kbptr,
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

    wl-kbptr = pkgs.wl-kbptr;
  };

  home.packages = [
    grim
    slurp
    swappy
    wf-recorder
    wl-clipboard
    # TODO: clipboard history
    xdg-utils

    wl-kbptr
  ];

  home.file = {
    # wl-kbptr config file
    "${config.xdg.configHome}/wl-kbptr".source =
      config.lib.file.mkOutOfStoreSymlink "${xdg_nixos.userConfigDir}/wl-kbptr";
  };
}
