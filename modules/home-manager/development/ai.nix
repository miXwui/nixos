# Enable AI development things

{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.ai;
in
{
  options.programs.ai = {
    enable = mkEnableOption "AI development environment";
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      acceleration = "rocm";
    };

    home.packages = with pkgs; [
      open-webui
    ];
  };
}
