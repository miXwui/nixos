{ lib, ... }:
let
  # https://www.iana.org/assignments/media-types/media-types.xhtml
  defaults = {
    # Doesn't support globs apparently, like `image/*`.
    "x-scheme-handler/http" = [ "firefox-private.desktop" ];
    "x-scheme-handler/https" = [ "firefox-private.desktop" ];
    "x-scheme-handler/chrome" = [ "firefox-private.desktop" ];

    "text/html" = [ "firefox-private.desktop" ];

    "application/x-extension-htm" = [ "firefox-private.desktop" ];
    "application/x-extension-html" = [ "firefox-private.desktop" ];
    "application/x-extension-shtml" = [ "firefox-private.desktop" ];
    "application/xhtml+xml" = [ "firefox-private.desktop" ];
    "application/x-extension-xhtml" = [ "firefox-private.desktop" ];
    "application/x-extension-xht" = [ "firefox-private.desktop" ];

    "video/mp4" = [ "mpv.desktop" ];
    "video/x-matroska" = [ "mpv.desktop" ];
    "video/quicktime" = [ "mpv.desktop" ];

    "image/apng" = [ "org.gnome.Loupe.desktop" ];
    "image/bmp" = [ "org.gnome.Loupe.desktop" ];
    "image/gif" = [ "org.gnome.Loupe.desktop" ];
    "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
    "image/png" = [ "org.gnome.Loupe.desktop" ];
    "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
    "image/tiff" = [ "org.gnome.Loupe.desktop" ];

    "application/x-bittorrent" = [ "qBitorrent.desktop" ];
  };
in
{
  options = {
    mime.defaults = lib.mkOption {
      description = "xdg-open mime defaults.";
      default = defaults;
    };
  };
}
