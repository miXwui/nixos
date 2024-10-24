{ pkgs, hyprpicker, ... }:

let
  makeDesktopItem = pkgs.makeDesktopItem;
  myDesktopItem = makeDesktopItem {
    name = "hyprpicker";
    exec = "hyprpicker";
    desktopName = "hypr Color Picker";
    categories = [
      "Application"
      "Graphics"
      "Utility"
    ];
  };
in
{
  _module.args = {
    hyprpicker = pkgs.hyprpicker;
  };

  home.packages = [
    myDesktopItem
    hyprpicker
  ];
}
