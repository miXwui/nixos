{ pkgs, unstable, ... }:
let
  wrapped = pkgs.writeShellScriptBin "contour" ''
    QT_STYLE_OVERRIDE= exec ${unstable.contour}/bin/contour
  '';

  contour = pkgs.symlinkJoin {
    name = "contour";
    paths = [
      wrapped
      unstable.contour
    ];
  };
in
{
  home.packages = [
    contour
  ];
}