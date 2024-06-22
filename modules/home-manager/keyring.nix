{ pkgs, seahorse, ... }:

{
  # Helpful article about GNOME Keyring/SSH with Sway,
  # but on Fedora (which I referred to when I was on Fedora):
  # https://major.io/p/use-gnome-keyring-with-sway/

  # We use a combination of GNOME Keyring and GNOME GCR for SSH
  # We're defining both in `hosts/base.nix` since we need gcr's path in
  # the manually created systemd service. For some reason it's not created
  # automatically.
  _module.args = {
    seahorse = pkgs.gnome.seahorse;
  };

  # Apparently gnome-keyring doesn't work from home-manager yet:
  # https://github.com/nix-community/home-manager/issues/1454
  # So we're starting the service in `base.nix`.

  # services.gnome-keyring = {
  #   enable = true;
  #   components = ["pkcs11" "secrets"];
  # };

  home.packages = [
    seahorse
  ];

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
  };
}
