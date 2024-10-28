{ config, gProgs, ... }:
let
  pauseAllMedia = builtins.readFile ../../home/.config/sway/scripts/pause-all-media.sh;
in
{
  # Pause media before suspending so e.g. I don't open the computer and media
  # embarassingly (or delightfully) starts playing in public (:
  #
  # Don't pause if I manually lock it, because I may want to just lock the
  # screen and keep music playing.
  #
  # Can't use a Systemd user unit since it has no access to system
  # `sleep.target` unless via a more complicated target.
  # See:
  # * https://github.com/systemd/systemd/issues/3312
  # * https://unix.stackexchange.com/questions/147904/systemd-user-unit-that-depends-on-system-unit-sleep-target
  # * https://unix.stackexchange.com/questions/149959/how-to-run-systemd-user-service-to-trigger-on-sleep-aka-suspend-hibernate
  systemd.services.pause-all-media-before-suspend = {
    description = "Pause all media before suspend";
    path = [ gProgs.playerctl ];
    script = ''
      # Apparently playerctl uses this variable to communicate with media players via D-Bus.
      export XDG_RUNTIME_DIR="/run/user/$(id -u ${config.main-user.username})"
      ${pauseAllMedia}
    '';
    serviceConfig = {
      User = "${config.main-user.username}";
      Type = "oneshot";
    };
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
  };
}
