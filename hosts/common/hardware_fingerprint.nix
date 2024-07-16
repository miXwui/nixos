# Enables fingerprint sensor for sudo, polkit, and lockscreen.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  fprintd = pkgs.fprintd;
in
{
  options = {
    hardware_fingerprint.enable = lib.mkEnableOption "enables config for fingerprint.";
  };

  config = lib.mkIf config.hardware_fingerprint.enable {
    # Fingerprint + PAM
    services.fprintd = {
      enable = true;
      package = fprintd;
    };

    # Turn off fingerprint for login that's used in e.g. SDDM because
    # fingerprint can't unlock keyring currently.
    security.pam.services.login.fprintAuth = false;

    # Swaylock: enter password, or press enter on empty password field to use fingerprint
    # https://github.com/swaywm/sway/issues/2773#issuecomment-427570877
    security.pam.services.swaylock = {
      text = ''
        auth sufficient ${fprintd}/lib/security/pam_fprintd.so
        auth sufficient pam_unix.so likeauth try_first_pass
      '';
    };

    security.pam.services.gtklock = {
      text = ''
        auth sufficient pam_unix.so try_first_pass likeauth nullok
        auth sufficient ${fprintd}/lib/security/pam_fprintd.so
      '';
    };

    security.pam.services.hyprlock = {
      text = ''
        auth sufficient pam_unix.so try_first_pass likeauth nullok
        auth sufficient ${fprintd}/lib/security/pam_fprintd.so timeout=10
      '';
    };
  };
}
