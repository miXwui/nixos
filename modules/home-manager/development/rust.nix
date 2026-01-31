# Enable Rust development things

{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.rust;
in
{
  options.programs.rust = {
    enable = mkEnableOption "Rust development environment";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rustc
      rustup

      # For AppFlowy
      pkg-config
      keybinder3
      gtk3
      libnotify
    ];
  };
}
