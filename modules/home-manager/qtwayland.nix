{ pkgs, qtwayland, ... }:

{
  _module.args = {
    qtwayland = pkgs.kdePackages.qtwayland;
  };

  home.packages = [
    qtwayland # requirement for qt apps
  ];

  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
  };
}
