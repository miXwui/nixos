{
  config,
  pkgs,
  xdg_nixos,

  playerctl,

  mpd,
  mpc,
  ncmpcpp,

  asciinema,
  ffmpeg,
  handbrake,
  imagemagick,
  inkscape,
  libdvdcss,
  yt-dlp,
  ...
}:
let
  enableMusicVisualization = true;
in
{
  _module.args = {
    mpd = pkgs.mpd;
    mpc = pkgs.mpc-cli; # TODO: change to mpc once https://nixpk.gs/pr-tracker.html?pr=353272 is pushed through.
    # https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/applications/audio/ncmpcpp/default.nix
    # `visualizerSupport` is disabled by default
    ncmpcpp = pkgs.ncmpcpp.override { visualizerSupport = enableMusicVisualization; };

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

    mpd
    mpc
    ncmpcpp

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

  programs.ncmpcpp = {
    enable = true;
    package = ncmpcpp;
    settings =
      {
        connected_message_on_startup = "no";

        # https://www.reddit.com/r/unixporn/comments/5qhyx0/comment/dcziasu/
        user_interface = "alternative";
        alternative_header_first_line_format = "$(11) █▓▒░ $b$(13)%a$(end)$/b ░▒▓█$(end)";
        alternative_header_second_line_format = "$(4)%t (%y)$(end)";
        alternative_ui_separator_color = 11;
      }
      // (
        if enableMusicVisualization then
          # https://wiki.archlinux.org/title/Ncmpcpp#Enabling_visualization
          {
            visualizer_data_source = "/tmp/mpd.fifo";
            visualizer_output_name = "my_fifo";
            visualizer_in_stereo = "yes";
            visualizer_type = "spectrum";
            visualizer_look = "+|";
          }
        else
          { }
      );
  };

  services = {
    # https://nixos.wiki/wiki/MPD
    mpd = {
      enable = true;
      package = mpd;
      # `xdg.userDirs.enable` is set to true in Home Manager, so the defined XDG
      # music directory is used. So no need to set `mumusicDirectory`.
      # musicDirectory = "";
      extraConfig =
        ''
          audio_output {
            type "pipewire"
            name "My PipeWire Output"
          }
        ''
        + (
          if enableMusicVisualization then
            ''
              audio_output {
                type                    "fifo"
                name                    "my_fifo"
                path                    "/tmp/mpd.fifo"
                format                  "44100:16:2"
              }
            ''
          else
            ""
        );

      # Optional:
      # network.listenAddress = "any"; # if you want to allow non-localhost connections
      network.startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket
    };

    mpd-mpris = {
      enable = true;
    };
  };

  home.file = {
    # mpv
    "${config.xdg.configHome}/mpv".source = config.lib.file.mkOutOfStoreSymlink "${xdg_nixos.userConfigDir}/mpv";
  };
}
