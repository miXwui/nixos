{ config, pkgs, fuzzel, ... }:
let
  makeDesktopItem = pkgs.makeDesktopItem;

  audioSinkNext = makeDesktopItem {
    name = "audio-sink-next";
    exec = "${config.xdg.configHome}/sway/scripts/audio-switch-next.sh";
    desktopName = "Audio Sink: Next";
    categories = [ "AudioVideo" "Audio" ];
  };
in
{
  _module.args = {
    fuzzel = pkgs.unstable.fuzzel;
  };

  home.packages = [
    fuzzel

    # Extra desktop entries
    audioSinkNext
  ];

  home.file = {
    "${config.xdg.configHome}/fuzzel" = {
      source = ../../home/.config/fuzzel;
      recursive = true;
    };
  };
}
