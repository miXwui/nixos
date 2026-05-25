# Enable C development things

{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.c;
in
{
  options.programs.c = {
    enable = mkEnableOption "C development environment";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Set gcc as higher priority to prevent collision, see:
      # https://github.com/nix-community/home-manager/issues/1668#issuecomment-1264298055
      (lib.hiPrio gcc)
      clang
    ];

    home.sessionVariables = {
      LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];
    };
  };
}
