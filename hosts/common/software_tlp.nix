# Enable TLP.

# [1] `services.tlp` does not currently have the `package` option:
# https://search.nixos.org/options?channel=24.05&from=0&size=50&sort=relevance&type=packages&query=tlp

# NOTE: TLP creates `/etc/udev/rules.d/85-tlp.rules`. Be careful not to create
# any new udev rules that override those, such as for handling change of power
# source (ac/battery).

{
  config,
  lib,
  hardware,
  ...
}:
let
  # TLP config files per hardware platform
  tlpConfig =
    {
      "amd_7840u" = builtins.readFile ../../etc/tlp.amd.7840u.conf;
      "intel_i7-1165g7" = builtins.readFile ../../etc/tlp.intel.i7-1165g7.conf;
      "intel_i7-6700hq_and_nvidia_gtx_960m" = builtins.readFile ../../etc/tlp.intel.i7-6700hq.and.nvidia.gtx-960m.conf;
      "qemu" = builtins.readFile ../../etc/tlp.qemu.conf;
      "live-image" = builtins.readFile ../../etc/tlp.live-image.conf;
    }
    .${hardware.platform};
in
{
  options = {
    software_tlp.enable = lib.mkEnableOption "enables config for TLP.";
    # software_tlp.package = lib.mkOption {
    #   default = pkgs.tlp;
    # }; # [1]
  };

  config = lib.mkIf config.software_tlp.enable {
    # Service
    services.tlp = {
      enable = true;
      # package = config.software_tlp.package; # [1]
    };

    # /etc/tlp.conf
    environment = {
      etc."tlp.conf".text = tlpConfig;
    };
  };
}
