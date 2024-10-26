# Enable power-profiles-daemon.

{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    software_ppd.enable = lib.mkEnableOption "enables config for power-profiles-daemon.";
    software_ppd.package = lib.mkOption {
      default = pkgs.power-profiles-daemon;
    };
  };

  config = lib.mkIf config.software_ppd.enable {
    services.power-profiles-daemon = {
      enable = true;
      package = config.software_ppd.package;
    };
  };
}
