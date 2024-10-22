{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    qbittorrent
  ];

  home.file = {
    "${config.xdg.configHome}/qBittorrent" = {
      source = ../../home/.config/qBittorrent;
      recursive = true;
    };
  };
}
