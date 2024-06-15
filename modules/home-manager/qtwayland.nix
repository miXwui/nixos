{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kdePackages.qtwayland # requirement for qt apps
  ];

  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
  };
}
