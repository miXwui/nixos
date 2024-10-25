{ config, xdg_nixos, ... }:

{
  home.file = {
    ".icons/default".source = config.lib.file.mkOutOfStoreSymlink "${xdg_nixos.rootDir}/home/.local/share/icons/volantes_light_cursors";
  };

  gtk = {
    cursorTheme = {
      name = "Volantes Light Cursors";
    };
  };
}
