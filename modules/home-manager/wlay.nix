{ pkgs, unstable, ... }:

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
  home.packages = [
    myDesktopItem
    unstable.wlay
  ];
}
