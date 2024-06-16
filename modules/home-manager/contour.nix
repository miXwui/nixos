{ pkgs, unstable, ... }:
let
  contour-pkg = unstable.contour;

  # https://github.com/NixOS/nixpkgs/issues/305959#issuecomment-2071263520
  # QT_STYLE_OVERRIDE= fixes `QQmlApplicationEngine failed to load component` error.
  wrapped = pkgs.writeShellScriptBin "contour" ''
    QT_STYLE_OVERRIDE= exec ${contour-pkg}/bin/contour
  '';

  fixed-contour = pkgs.symlinkJoin {
    name = "contour";
    paths = [
      wrapped
      contour-pkg
    ];
  };
in
{
  _module.args = {
    contour = fixed-contour;
  };

  home.packages = [
    fixed-contour
  ];
}