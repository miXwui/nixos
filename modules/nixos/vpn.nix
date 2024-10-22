{ pkgs, ... }:
let
  pia_manual-connections 
    = pkgs.callPackage ../../packages/pia_manual-connections { };
in
{
  networking.wireguard.enable = true;

  ## systemd-resolved
  # For e.g.enabling PIA manual-connection scripts to set DNS configuration.
  services.resolved.enable = true;

  environment.systemPackages = [ pia_manual-connections ];
}
