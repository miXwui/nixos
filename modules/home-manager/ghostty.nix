{
  config,
  pkgs,
  xdg_nixos,
  ...
}:
let
  # Feature requests:
  # Copy mode: https://github.com/ghostty-org/ghostty/discussions/3488
  ghostty = pkgs.ghostty;
in
{
  _module.args = {
    ghostty = ghostty;
  };

  programs.ghostty = {
    enable = true;
    package = ghostty;
  };

  home.file = {
    "${config.xdg.configHome}/ghostty".source =
      config.lib.file.mkOutOfStoreSymlink "${xdg_nixos.userConfigDir}/ghostty";
  };
}
