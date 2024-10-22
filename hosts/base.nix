# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, hardware, ... }:
let
  ### Sway
  sway = rec {
    swayfx.enable = true; # toggling this will toggle pkg below.
    pkg = if swayfx.enable then pkgs.unstable.swayfx else pkgs.unstable.sway;
    lockCommand = "hyprlock"; # "swaylock -d" or "gtklock -d" or "hyprlock"
  };

  ### TLP
  tlpConfig = {
    "amd_7840u" = builtins.readFile ../etc/tlp.amd.7840u.conf;
    "intel_i7-1165g7" = builtins.readFile ../etc/tlp.intel.i7-1165g7.conf;
    "intel_i7-6700hq_and_nvidia_gtx_960m" = builtins.readFile ../etc/tlp.intel.i7-6700hq.and.nvidia.gtx-960m.conf;
    "qemu" = builtins.readFile ../etc/tlp.qemu.conf;
    "live-image" = builtins.readFile ../etc/tlp.live-image.conf;
  }.${hardware.platform};

  ### GParted with xhost root
  my-gparted-with-xhost-root = pkgs.gparted.overrideAttrs (previousAttrs: {
    configureFlags = previousAttrs.configureFlags ++ [ "--enable-xhost-root" ];
  });

  # fedoraKernel = (pkgs.unstable.linuxKernel.manualConfig rec {
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
  ### IMPORTS ###
  imports = [
    ../modules/nixos/main-user.nix
    ./common/hardware_input-laptop.nix
    ./common/hardware_fingerprint.nix
    ./common/hardware_bluetooth.nix
    ./common/hardware_ssd.nix
    inputs.home-manager.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    # Custom packages
    ../modules/nixos/drm_amd.nix
    ../modules/nixos/vpn.nix
  ];

  ### SOPS ###
  sops = {
    defaultSopsFile = /home/${config.main-user.username}/nixos/secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    validateSopsFiles = false; # to allow the file to be outside the git repo/nix store

    age.keyFile = /home/${config.main-user.username}/nixos/secrets/.config/sops/age/keys.txt;
  };

  ### KERNEL ###
  # https://nixos.wiki/wiki/Linux_kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # Pin a specific kernel.
  # Warning: This will compile the kernel and take a while.
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_11.override {
    argsOverride = rec {
      src = pkgs.fetchurl {
            url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
            sha256 = "sha256-BXJj0K/BfVJTeUr9PSObpNpKpzSyL6NsFmX0G5VEm3M=";
      };
      version = "6.11.3";
      modDirVersion = "6.11.3";
      };
  });
  # boot.kernelPackages = pkgs.linuxPackagesFor fedoraKernel;
  # boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages; # might need if latest doesn't support zfs
  boot.supportedFilesystems = [ "bcachefs" ];

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
        "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
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
      sway = sway;
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
    SOPS_AGE_KEY_FILE = "/home/${config.main-user.username}/nixos/secrets/.config/sops/age/keys.txt";
  };

  ### SHELL ALIASES ###
  environment.shellAliases = {};

  ### DISPLAY MANAGER ###
  services.displayManager = {
    sddm.enable = true;
    sddm.wayland.enable = true;
    sessionPackages = [ sway.pkg ];
  };

  ### SERVICES ###

  ## OpenSSH daemon
  # https://www.reddit.com/r/NixOS/comments/16mbn41/install_but_dont_enable_openssh_sshd_service/
  # This adds systemd.services.sshd to the config and automatically enables it:
  services.openssh.enable = true;
  # so we disable automatic start up here:
  systemd.services.sshd.wantedBy = lib.mkForce [ ];

  ## TLP
  services.tlp.enable = true;

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
    swaylock = {};
    gtklock = {};
    hyprlock = {};
  };

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
      google_api_key  = { owner = config.main-user.username; };
      ssh_private_key = { owner = config.main-user.username; };
      ssh_public_key  = { owner = config.main-user.username; };
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
  environment = {
    etc."tlp.conf".text = tlpConfig;
  };

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
