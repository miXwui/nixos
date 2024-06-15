{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    gcolor3
  ];

 home.file = {
  "${config.xdg.configHome}/gcolor3" = {
    source = ../../home/.config/gcolor3;
    recursive = true;
  };
 };
}