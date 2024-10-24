{ pkgs, wlay, ... }:

let
  makeDesktopItem = pkgs.makeDesktopItem;
  myDesktopItem = makeDesktopItem {
    name = "wlay";
    exec = "wlay";
    desktopName = "wlay";
    categories = [ "Application" "Graphics" "Utility" ];
  };
in
{
  _module.args = {
    wlay = pkgs.wlay;
  };

  home.packages = [
    myDesktopItem
    wlay
  ];
}
