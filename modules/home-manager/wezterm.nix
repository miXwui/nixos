{
  config,
  pkgs,
  xdg_nixos,
  ...
}:

let
  wezterm = pkgs.wezterm;
in
{
  _module.args = {
    wezterm = wezterm;
  };

  programs.wezterm = {
    enable = true;
    package = wezterm;
  };

  home.file = {
    "${config.xdg.configHome}/wezterm/wezterm.lua".source =
      config.lib.file.mkOutOfStoreSymlink "${xdg_nixos.userConfigDir}/wezterm/wezterm.lua";
  };
}
