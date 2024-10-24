{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../base.nix
  ];

  _module.args.hardware.platform = "live-image";
}
