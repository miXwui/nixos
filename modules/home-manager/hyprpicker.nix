{ pkgs, ... }:

let
  makeDesktopItem = pkgs.makeDesktopItem;
  myDesktopItem = makeDesktopItem {
    name = "hyprpicker";
    exec = "hyprpicker";
    desktopName = "hypr Color Picker";
    categories = [ "Application" "Graphics" "Utility" ];
  };
in
{
  home.packages = [
    myDesktopItem
    pkgs.hyprpicker
  ];
}