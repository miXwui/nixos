{ pkgs, lib, ... }:

let
    nautilus = pkgs.nautilus;
    nemo-with-extensions = pkgs.nemo-with-extensions;
    kdePackages.dolphin = pkgs.kdePackages.dolphin;
    xfce.thunar = pkgs.xfce.thunar;
    spacedrive = pkgs.spacedrive;
    yazi = pkgs.yazi;

    file-roller = pkgs.file-roller;
    sushi = pkgs.sushi;
    gnome-font-viewer = pkgs.gnome-font-viewer;
in
{
  _module.args = {
    nautilus = nautilus;
    nemo-with-extensions = nemo-with-extensions;
    kdePackages.dolphin = kdePackages.dolphin;
    xfce.thunar = xfce.thunar;
    spacedrive = spacedrive;
    yazi = yazi;

    file-roller = file-roller;
    sushi = sushi;
  };

  home.packages = [
    # File managers
    nautilus
    nemo-with-extensions
    kdePackages.dolphin
    xfce.thunar
    spacedrive
    yazi

    file-roller
    sushi
    gnome-font-viewer
  ];

  home.sessionVariables = {
    # Fix for Nautilus Audio/Video Properties
    # > Your GStreamer installation is missing a plug-in.
    # https://github.com/NixOS/nixpkgs/issues/195936#issuecomment-1366902737
    GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (
      with pkgs.gst_all_1;
      [
        gst-plugins-good
        gst-plugins-bad
        gst-plugins-ugly
        gst-libav
      ]
    );
  };
}
