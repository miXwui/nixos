# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  xdg_nixos_dir = "/home/${config.main-user.username}/nixos";

  # Warning: specifying a version other than latest will compile the kernel and
  # take a while.
  linux_kernel = {
    # Set `pin` to `false` to use the latest kernel version in nixpkgs.
    # Set `pin  to `true` major/minor/patch below to compile a specific version.
    # Warning: compilation will take a while since it's not pulling from a
    # binary cache.
    pin = false;
    major = 6;
    minor = 11;
    patch = 3;
    sha256 = "sha256-BXJj0K/BfVJTeUr9PSObpNpKpzSyL6NsFmX0G5VEm3M=";
  };

  ### Sway
  sway = rec {
    swayfx.enable = true; # toggling this will toggle pkg below.
    pkg = if swayfx.enable then pkgs.swayfx else pkgs.sway;
    # Make sure not to daemonize (like with `swaylock -f` and in
    # `home/.swaylock/ config`) so that Dunst can properly resume after
    # unlocking, instead of after locking.
    # See: `home/.config/sway/scripts/lock-screen.sh`
    lockCommand = "swaylock"; # "swaylock" or "gtklock" or "hyprlock"
  };

  # Global programs
  gProgs = {
    coreutils = pkgs.coreutils;
    logger = pkgs.logger;
    ppd = config.software_ppd.package;
    playerctl = pkgs.playerctl;
  };

  ### GParted with xhost root
  my-gparted-with-xhost-root = pkgs.gparted.overrideAttrs (previousAttrs: {
    configureFlags = previousAttrs.configureFlags ++ [ "--enable-xhost-root" ];
  });

  # fedoraKernel = (pkgs.linuxKernel.manualConfig rec {
  #   version = "6.9.11";
  #   modDirVersion = version;
  #   configfile = ./kernel-x86_64-fedora.noquotes.config;
  #   allowImportFromDerivation = true;
  #   src = pkgs.fetchurl {
  #     # https://github.com/NixOS/nixpkgs/blob/28b3994c14c4b3e36aa8b6c0145e467250c8fbb8/pkgs/os-specific/linux/kernel/mainline.nix#L19
  #     url = "https://cdn.kernel.org/pub/linux/kernel/v${lib.versions.major version}.x/linux-${version}.tar.gz";
  #     sha256 = "0f69315a144b24a72ebd346b1ca571acef10e9609356eb9aa4c70ef3574eff62";
  #   };
  # # https://github.com/NixOS/nixpkgs/issues/216529
  # # https://github.com/NixOS/nixpkgs/pull/288154#pullrequestreview-1901852446
  # }).overrideAttrs(old: {
  #   passthru = old.passthru // {
  #     features = {
  #       ia32Emulation = true;
  #       efiBootStub = true;
  #     };
  #   };
  # });

in
{
  ### MODULE ARGS ###
  _module.args = {
    xdg_nixos_dir = xdg_nixos_dir;
    gProgs = gProgs;
  };

  ### IMPORTS ###
  imports = [
    ../modules/nixos/main-user.nix
    ./common/hardware_input-laptop.nix
    ./common/hardware_fingerprint.nix
    ./common/hardware_bluetooth.nix
    ./common/hardware_ssd.nix
    ./common/software_power_management.nix
    ./common/software_sddm.nix
    ./common/boot_debug.nix
    ./common/suspend-then-hibernate.nix
    inputs.home-manager.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    # Custom packages
    ../modules/nixos/drm_amd.nix
    ../modules/nixos/vpn.nix
  ];

  ### SOPS ###
  sops = {
    defaultSopsFile = "${xdg_nixos_dir}/secrets/secrets.yaml";
    defaultSopsFormat = "yaml";
    validateSopsFiles = false; # to allow the file to be outside the git repo/nix store

    age.keyFile = "${xdg_nixos_dir}/secrets/.config/sops/age/keys.txt";
  };

  ### KERNEL ###
  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages =
    if linux_kernel.pin != true then
      pkgs.linuxPackages_latest
    else
      # Pin a specific kernel.
      # Warning: This will compile the kernel and take a while.
      let
        major = toString linux_kernel.major;
        minor = toString linux_kernel.minor;
        patch = toString linux_kernel.patch;
        sha256 = linux_kernel.sha256;
      in
      pkgs.linuxPackagesFor (
        pkgs.${"linux_${major}_${minor}"}.override {
          argsOverride = rec {
            src = pkgs.fetchurl {
              url = "mirror://kernel/linux/kernel/v${major}.x/linux-${version}.tar.xz";
              sha256 = sha256;
            };
            version = "${major}.${minor}.${patch}";
            modDirVersion = version;
          };
        }
      );
  # boot.kernelPackages = pkgs.linuxPackagesFor fedoraKernel;
  # boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages; # might need if latest doesn't support zfs
  boot.supportedFilesystems = [ "bcachefs" ];

  # Toggle more verbose logging for boot, etc.
  # See `hosts/common/boot_debug.nix`
  boot_debug = {
    enable = false;
    network_no_wait_online = false;
    network_no_wait_startup = false;
    home_manager_verbose = false;
  };

  # Magic SysRq
  boot.kernel.sysctl = {
    "kernel.sysrq" = 254; # enable all features except nicing of all RT tasks
  };

  ### NETWORK ###
  networking.hostName = "nixos"; # Define your hostname.
  # Disable wireless support via wpa_supplicant since it's enabled by default in
  # `/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix`:
  # https://github.com/NixOS/nixpkgs/blob/0bf03b32dcb0a80013b0ad3eb2446947027cfc4d/nixos/modules/profiles/installation-device.nix#L82
  # and we can't use networking.networkmanager with networking.wireless.
  networking.wireless.enable = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Firewall
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  ### TIME ###
  # Set your time zone.
  time.timeZone = "America/Chicago";

  ### i18n/Internationalization ###
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  ### EXTRA ###
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # TODO: delete when removing SublimeText4 from editors.
  # https://github.com/NixOS/nixpkgs/issues/239615
  # https://github.com/sublimehq/sublime_text/issues/5984
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];

  # Experimental features
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  ### DRIVES ###
  # Enable automounting USB/drives
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  ### PRINTERS ###
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ ];
  };

  # Mostly used for printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = false;
    openFirewall = true;
  };

  ### AUDIO ###
  ## Enable sound with pipewire.
  # https://nixos.wiki/wiki/PipeWire
  # Remove sound.enable or set it to false if you had it set previously, as sound.enable is only meant for ALSA-based configurations
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    # Also needed for xdg-desktop-portal-wlr:
    # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/FAQ#what-is-pipewire
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  ## PipeWire Bluetooth
  # https://nixos.wiki/wiki/PipeWire#Bluetooth_Configuration
  services.pipewire.wireplumber.extraConfig = {
    "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
      "bluez5.roles" = [
        "hsp_hs"
        "hsp_ag"
        "hfp_hf"
        "hfp_ag"
      ];
    };
  };

  ## PipeWire low latency
  # https://nixos.wiki/wiki/PipeWire#Low-latency_setup
  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    context.properties = {
      default.clock.rate = 48000;
      default.clock.quantum = 32;
      default.clock.min-quantum = 32;
      default.clock.max-quantum = 32;
    };
  };

  ### USER ####
  # Define a user account. Don't forget to set a password with ‘passwd’.
  main-user.enable = true;
  main-user.username = "mwu";
  main-user.fullname = "Michael Wu";

  ### HOME MANAGER ###
  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = {
      inherit inputs;
      # Dirs
      xdg_nixos_dir = xdg_nixos_dir;

      # Desktop environment
      sway = sway;

      # Global programs
      gProgs = gProgs;

      # Configs
      sops = config.sops;
    };
    users = {
      "mwu" = import ./home.nix;
    };
    backupFileExtension = "nixbak";
    # Pass nixpkgs/overlays from system configuration.
    # Alternatively, this can be removed/set to false so Home Manager is isolated.
    # https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module
    useGlobalPkgs = true;
  };

  ### ENVIRONMENT VARIABLES ###
  environment.variables = {
    # https://github.com/getsops/sops/blob/3458c3534f215012d1f813d8507f531239bf1485/README.rst?plain=1#L211
    SOPS_AGE_KEY_FILE = "${xdg_nixos_dir}/secrets/.config/sops/age/keys.txt";
  };

  ### SHELL ALIASES ###
  environment.shellAliases = { };

  ### DISPLAY MANAGER ###
  services.displayManager = {
    sddm = config.software_sddm.config;
    sessionPackages = [ sway.pkg ];
  };

  ### SERVICES ###

  ## OpenSSH daemon
  # https://www.reddit.com/r/NixOS/comments/16mbn41/install_but_dont_enable_openssh_sshd_service/
  # This adds systemd.services.sshd to the config and automatically enables it:
  services.openssh.enable = true;
  # so we disable automatic start up here:
  systemd.services.sshd.wantedBy = lib.mkForce [ ];

  ## Power management
  software_power_management = {
    enable = true;
    powerUtil = "tlp"; # tlp or ppd
  };

  ## GeoClue
  services.geoclue2 = {
    enable = true;
    # geoProviderUrl = "https://beacondb.net/v1/geolocate"; # TODO: possibly switch to this
  };

  # Add our own Google geolocate API key into GeoClue's [wifi] url= config since:
  # [nixos/geoclue2: not working because Mozilla Location Service is retiring](https://github.com/NixOS/nixpkgs/issues/321121)
  systemd.services.geoclue-config = lib.mkIf (config.sops.secrets ? google_api_key) {
    description = "Add our own Google geolocate API key into GeoClue's [wifi] url= config.";
    script = ''
      mkdir -p /etc/geoclue/conf.d
      echo "
      [wifi]
      enable=true
      url=https://www.googleapis.com/geolocation/v1/geolocate?key=$(cat ${config.sops.secrets.google_api_key.path})
      " > /etc/geoclue/conf.d/90-custom-wifi.conf
    '';
    wantedBy = [ "multi-user.target" ];
  };

  ## fwupd
  services.fwupd.enable = true;
  services.fwupd.extraRemotes = [ "lvfs-testing" ];

  ## PAM
  security.pam.services = {
    # https://nixos.wiki/wiki/Sway#Swaylock_cannot_be_unlocked_with_the_correct_password
    swaylock = { };
    gtklock = { };
    hyprlock = { };
  };

  # Allow programs run by the `users` group to request real-time priority
  # https://nixos.wiki/wiki/Sway#Inferior_performance_compared_to_other_distributions
  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }
  ];

  ## Polkit
  security.polkit = {
    # https://nixos.wiki/wiki/Sway#Using_Home_Manager
    enable = true;
    # https://nixos.wiki/wiki/Polkit#Reboot/poweroff_for_unprivileged_users
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          subject.isInGroup("users")
            && (
              action.id == "org.freedesktop.login1.reboot" ||
              action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
              action.id == "org.freedesktop.login1.power-off" ||
              action.id == "org.freedesktop.login1.power-off-multiple-sessions"
            )
          )
        {
          return polkit.Result.YES;
        }
      })
    '';
  };

  # systemd user service for polkit defined in `modules/home-manager/sway.nix`.

  ## Keyring
  # Doesn't work from Home Manager yet, so we enable it here.
  # This doesn't create the necessary systemd user services, so we create them in:
  # `modules/home-manager/keyring.nix`.
  services.gnome.gnome-keyring.enable = true;

  ### SOPS ###
  sops = {
    secrets = {
      google_api_key = {
        owner = config.main-user.username;
      };
      ssh_private_key = {
        owner = config.main-user.username;
      };
      ssh_public_key = {
        owner = config.main-user.username;
      };
    };
  };

  ### PROGRAMS ###
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.light.enable = true;
  programs.fish.enable = true;
  programs.dconf.enable = true; # needed for Gnome color scheme settings, etc.

  ## Networking
  # KDE Connect
  # Crashes using Home Manager with `services.kdeconnect` so we set up here.
  programs.kdeconnect = {
    enable = true;
    package = pkgs.kdePackages.kdeconnect-kde;
  };

  # Wireshark
  # Users also need to be added to the `wireshark` group.
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  programs.mtr.enable = true;

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  ### SYSTEM PACKAGES ###
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.

    # SDDM theme
    config.software_sddm.sddm-theme
    config.software_sddm.sddm-background
    config.software_sddm.sddm-cursors

    # Global programs
    coreutils
    logger

    # Utilities
    drm_info

    # Enable automounting USB/drives
    udisks
    # udiskie # service/tray added via Home Manager
    usbutils
    # GParted
    my-gparted-with-xhost-root
    xorg.xhost

    # Secrets
    sops
    age
    ssh-to-age

    # Audio
    pavucontrol
    helvum
  ];

  ### ETC FILES ###
  environment = { };

  ### FONTS ###
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      cantarell-fonts
      cascadia-code
      font-awesome
    ];

    fontconfig = {
      defaultFonts = {
        #serif = [ "" ];
        sansSerif = [ "Cantarell Regular" ];
        monospace = [ "Cascadia Mono" ];
      };
    };
  };

  ### MISC ###

  # Ignore power button press.
  # `suspend-then-hibernate` instead of just `suspend`.
  services.logind.powerKey = "ignore";
  services.logind.rebootKey = "ignore";
  services.logind.suspendKey = "suspend-then-hibernate";
  services.logind.lidSwitch = "suspend-then-hibernate";

  systemd.sleep.extraConfig = ''
    AllowHibernation=yes
    AllowSuspendThenHibernate=yes
    HibernateDelaySec=60min
    HibernateMode=platform
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
