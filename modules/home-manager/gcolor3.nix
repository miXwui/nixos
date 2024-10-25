{
  pkgs,
  config,
  xdg_nixos,
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
    "${config.xdg.configHome}/gcolor3".source = config.lib.file.mkOutOfStoreSymlink "${xdg_nixos.userConfigDir}/gcolor3";
  };
}
