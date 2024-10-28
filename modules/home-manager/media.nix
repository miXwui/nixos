{
  config,
  pkgs,
  xdg_nixos,

  playerctl,
  
  asciinema,
  ffmpeg,
  handbrake,
  imagemagick,
  inkscape,
  libdvdcss,
  yt-dlp,
  ...
}:

{
  _module.args = {
    asciinema = pkgs.asciinema;
    ffmpeg = pkgs.ffmpeg;
    handbrake = pkgs.handbrake;
    imagemagick = pkgs.imagemagick;
    inkscape = pkgs.inkscape;
    libdvdcss = pkgs.libdvdcss;
    yt-dlp = pkgs.yt-dlp.overrideAttrs (old: {
      patches = [ ../../packages/yt-dlp/firefox.patch ];
    });
  };

  home.packages = [
    playerctl
    
    asciinema
    ffmpeg
    handbrake
    imagemagick
    inkscape
    libdvdcss
    yt-dlp
  ];

  programs.mpv = {
    enable = true;
    scripts = [
      pkgs.mpvScripts.mpris
      pkgs.mpvScripts.uosc
    ];
  };

  home.file = {
    # mpv
    "${config.xdg.configHome}/mpv".source = config.lib.file.mkOutOfStoreSymlink "${xdg_nixos.userConfigDir}/mpv";
  };
}
