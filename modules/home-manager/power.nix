{
  pkgs,
  powertop,
  powerstat,
  poweralertd,
  ...
}:

{
  _module.args = {
    powertop = pkgs.powertop;
    powerstat = pkgs.powerstat;
    poweralertd = pkgs.poweralertd;
  };

  home.packages = [
    powertop
    powerstat
    # [1] Needed to run in PATH, even though it's already installed with
    # `services.poweralertd.enable` because that doesn't have a `package`
    # option.
    poweralertd # [1]
  ];

  services = {
    poweralertd.enable = true; # [1]
  };
}
