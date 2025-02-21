{ pkgs, ... }:
let
  pia_manual-connections = pkgs.callPackage ../../packages/pia_manual-connections { };
in
{
  networking.wireguard.enable = true;

  ## systemd-resolved
  # For e.g.enabling PIA manual-connection scripts to set DNS configuration.
  services.resolved.enable = true;

  services.mullvad-vpn.enable = true;

  environment.systemPackages = with pkgs; [
    pia_manual-connections
    mullvad
    mullvad-vpn
    mullvad-browser
  ];
}
