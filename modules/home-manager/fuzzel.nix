{
  config,
  pkgs,
  xdg_nixos_dir,
  fuzzel,
  ...
}:
let
  makeDesktopItem = pkgs.makeDesktopItem;

  audioSinkNext = makeDesktopItem {
    name = "audio-sink-next";
    exec = "${config.xdg.configHome}/sway/scripts/audio-switch-next.sh";
    desktopName = "Audio Sink: Next";
    categories = [
      "AudioVideo"
      "Audio"
    ];
  };
in
{
  _module.args = {
    fuzzel = pkgs.fuzzel;
  };

  home.packages = [
    fuzzel

    # Extra desktop entries
    audioSinkNext
  ];

  home.file = {
    "${config.xdg.configHome}/fuzzel".source = config.lib.file.mkOutOfStoreSymlink "${xdg_nixos_dir}/home/.config/fuzzel";
  };
}
