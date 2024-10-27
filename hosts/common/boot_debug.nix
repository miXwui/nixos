# Enable verbose logging for boot/Home Manager and other boot options.

{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    boot_debug = {
      enable = lib.mkEnableOption "enables more verbose boot/Home Manager logging.";
      network_no_wait_online = lib.mkEnableOption "don't wait for network online";
      network_no_wait_startup = lib.mkEnableOption "don't wait for network startup";
      home_manager_verbose = lib.mkEnableOption "enable verbose logging for Home Manager";
    };
  };

  config = lib.mkMerge [
    # Enable verbose boot debug logging.
    # https://nixos.org/manual/nixos/unstable/#sec-boot-problems
    (lib.mkIf config.boot_debug.enable {
      # https://www.kernel.org/doc/Documentation/admin-guide/kernel-parameters.txt
      boot.consoleLogLevel = 8;
      boot.kernelParams = [
        "systemd.log_level=debug"
        "systemd.log_target=console"
      ];
    })

    # Don't wait for NetworkManager online during boot.
    (lib.mkIf config.boot_debug.network_no_wait_online {
      systemd.services.NetworkManager-wait-online.enable = false;
    })

    # Don't wait for network startup
    (lib.mkIf config.boot_debug.network_no_wait_startup {
      # https://old.reddit.com/r/NixOS/comments/vdz86j/how_to_remove_boot_dependency_on_network_for_a
      systemd = {
        targets.network-online.wantedBy = pkgs.lib.mkForce [ ]; # Normally ["multi-user.target"]
        services.NetworkManager-wait-online.wantedBy = pkgs.lib.mkForce [ ]; # Normally ["network-online.target"]
      };
    })

    # Enable verbose Home Manager logging.
    (lib.mkIf config.boot_debug.home_manager_verbose {
      home-manager.verbose = true;
    })
  ];
}
