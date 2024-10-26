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
    poweralertd = pkgs.poweralertd.overrideAttrs (old: {
      patches = [
        ../../packages/poweralertd/o-option.patch
        ../../packages/poweralertd/I-option.patch # [2]
      ];
    });
  };

  home.packages = [
    powertop
    powerstat
    # [1] Needed to run in PATH, even though it's already installed with
    # `services.poweralertd.enable` because that doesn't have a `package`
    # option.
    poweralertd # [1]
  ];

  ### poweralertd

  # services = {
  #   poweralertd = {
  #     enable = true; # [1]
  #     extraArgs = [ "I" ]; for patch [2]
  #   };
  # };

  # Home Manager oesn't have services.poweralertd.package option yet.
  # https://github.com/nix-community/home-manager/blob/master/modules/services/poweralertd.nixF
  # So I'm setting this up manually.

  systemd.user.services.poweralertd = {
    Unit = {
      Description = "UPower-powered power alerter";
      Documentation = "man:poweralertd(1)";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install.WantedBy = [ "graphical-session.target" ];

    Service = {
      Type = "simple";
      ExecStart = "${poweralertd}/bin/poweralertd -I";
      Restart = "always";
    };
  };
}
