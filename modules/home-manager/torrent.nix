{
  config,
  pkgs,
  xdg_nixos,
  ...
}:
{
  home.packages = with pkgs; [
    qbittorrent
  ];

  home.file = {
    "${config.xdg.configHome}/qBitorrent".source = config.lib.file.mkOutOfStoreSymlink "${xdg_nixos.userConfigDir}/qBittorrent";
  };
}
