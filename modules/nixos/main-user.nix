{ lib, config, pkgs, ... }:

let
  cfg = config.main-user;
in
{
  options.main-user = {
    enable
      = lib.mkEnableOption "enable user module";

    username = lib.mkOption {
      default = "mainuser";
      description = ''
        username
      '';
    };

    fullname = lib.mkOption {
    default = "First Last";
    description = ''
      name of user
    '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.username} = {
      isNormalUser = true;
      initialPassword = "12345";
      description = cfg.fullname;
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        firefox
        unstable.vscode
        helix
      ];
      shell = pkgs.fish;
    };
  };
}
