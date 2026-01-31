{
  imports = [
    ./sway.nix
    ./power.nix
    ./wayland-utils.nix
    ./keyring.nix
    ./ssh.nix
    ./cursors.nix
    ./dunst.nix
    ./fish.nix
    ./foot.nix
    ./wezterm.nix
    # ./contour.nix #https://github.com/NixOS/nixpkgs/issues/345752
    ./fuzzel.nix
    ./files.nix
    ./mime.nix
    ./gcolor3.nix
    ./hyprpicker.nix
    ./git.nix
    ./qtwayland.nix
    ./wlay.nix
    ./xdg-desktop-portals.nix
    ./editors.nix
    ./media.nix
    ./language-servers.nix
    ./backup.nix
    ./security.nix
    ./torrent.nix
    # Development
    ./development/base.nix
    ./development/c.nix
    ./development/rust.nix
  ];
}
