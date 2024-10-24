{
  config,
  pkgs,
  xdg-desktop-portal-wlr,
  xdg-desktop-portal-gtk,
  dunst,
  slurp,
  fuzzel,
  ...
}:

{
  _module.args = {
    xdg-desktop-portal-wlr = pkgs.xdg-desktop-portal-wlr;
    xdg-desktop-portal-gtk = pkgs.xdg-desktop-portal-gtk;
  };

  # XDG Desktop Portals
  # https://nixos.org/manual/nixos/stable/#sec-wayland
  # https://discourse.nixos.org/t/why-does-enabling-xdg-portal-install-so-many-packages/28283
  xdg.portal = {
    enable = true;
    config = {
      # https://github.com/emersion/xdg-desktop-portal-wlr/blob/master/README.md#running
      sway = {
        # Use xdg-desktop-portal-gtk for every portal interface...
        default = [ "gtk" ];
        # ... except for the ScreenCast, Screenshot and Secret
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
      };
    };
    extraPortals = with pkgs; [
      # https://github.com/emersion/xdg-desktop-portal-wlr

      # This needs to be added to Sway config:
      # https://github.com/emersion/xdg-desktop-portal-wlr/blob/master/README.md#running
      # exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway

      # Pipewire is required for xdg-desktop-portal-wlr:
      # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/FAQ#what-is-pipewire
      xdg-desktop-portal-wlr

      # For gcolor3, etc.
      xdg-desktop-portal-gtk
    ];
  };

  home.file = {
    "${config.xdg.configHome}/xdg-desktop-portal-wlr/config" = {
      text = ''
        # https://github.com/emersion/xdg-desktop-portal-wlr/blob/master/xdg-desktop-portal-wlr.5.scd

        [screencast]
        # Toggle dunst notifications when screensharing
        exec_before=${dunst}/bin/dunstctl set-paused toggle true
        exec_after=${dunst}/bin/dunstctl set-paused false

        # Select output with slurp
        chooser_type=simple
        chooser_cmd=${slurp}/bin/slurp -f %o -or

        # Can also select via dmenu/etc.
        # chooser_type=dmenu
        # chooser_cmd=${fuzzel}/bin/fuzzel --dmenu
      '';
    };
  };
}
