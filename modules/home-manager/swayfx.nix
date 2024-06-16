{ lib, config, ... }:

{
  options = {
    swayfx.enable = lib.mkEnableOption "enables SwayFX";
  };

  config = lib.mkIf config.swayfx.enable {
     home.file = {
      "${config.xdg.configHome}/sway/swayfx" = {
        text = ''
          ### SwayFX ###
          # window corner radius in px
          corner_radius 10

          # Window background blur
          blur on
          blur_xray off
          blur_passes 2
          blur_radius 5

          shadows on
          shadows_on_csd off
          shadow_blur_radius 20
          shadow_color #0000007F

          # LayerShell effects (to blur panels / notifications etc)
          # The current layer namespaces can be shown with
          # `swaymsg -r -t get_outputs | jq '.[0].layer_shell_surfaces | .[] | .namespace'`
          # or `sleep 1; swaymsg -r -t get_outputs` in `layer_shell_surfaces` since
          # `launcher` and `notifications` weren't showing with the command above.
          layer_effects "waybar" blur enable; shadows enable; corner_radius 10
          layer_effects "launcher" blur enable; shadows enable; corner_radius 10
          layer_effects "notifications" blur enable; shadows enable; corner_radius 10

          # inactive window fade amount. 0.0 = no dimming, 1.0 = fully dimmed
          default_dim_inactive 0.0
          dim_inactive_colors.unfocused #000000FF
          dim_inactive_colors.urgent #900000FF
        '';
      };
    };
  };
}
