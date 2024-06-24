# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, ... }:
let
  ### Sway
  sway = {
    pkg = pkgs.unstable.swayfx; # sway or swayfx
    swayfx.enable = true;
    lockCommand = "hyprlock"; # "swaylock -d" or "gtklock -d" or "hyprlock"
  };

  ### TLP
  tlpConfig = builtins.readFile ../etc/tlp.conf;

  ### keyd
  keydConfig = builtins.readFile ../etc/keyd/default.conf;

  ### gcr_4
  #
  # Use gcr for ssh instead of from gnome-keyring:
  # https://gitlab.gnome.org/GNOME/gnome-keyring/-/merge_requests/60
  #
  # Also see notes in `modules/home-manager/keyring.nix`.
  #
  # `gcr` package is an older version 3 that crashes:
  # https://github.com/NixOS/nixpkgs/blob/13edc842adf7e4889ab39c0703e772d4c1fa05b1/pkgs/development/libraries/gcr/default.nix#L29
  # `gcr4` exists, so we use that, and override to enable ssh-agent since it's disabled here:
  # https://github.com/NixOS/nixpkgs/blob/6c2520b3debc83b26ba56e0b47a82d79d5b50c23/pkgs/development/libraries/gcr/4.nix#L73-L75
  gcr-with-ssh = pkgs.gcr_4.overrideAttrs (previousAttrs: {
    # Add `openssh` which has the required `ssh-add`:
    nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ pkgs.openssh ];
    # Enable `ssh_agent` and `systemd`:
    # https://gitlab.gnome.org/GNOME/gcr/-/blob/78e5f89016635b4c4922e63f599b8ec81ea4b923/meson.build
    # https://gitlab.gnome.org/GNOME/gcr/-/blob/78e5f89016635b4c4922e63f599b8ec81ea4b923/meson_options.txt
    mesonFlags = lib.lists.remove "-Dssh_agent=false" previousAttrs.mesonFlags ++ [ "-Dssh_agent=true" ];
  });

  ### GParted with xhost root
  my-gparted-with-xhost-root = pkgs.gparted.overrideAttrs (previousAttrs: {
    configureFlags = previousAttrs.configureFlags ++ [ "--enable-xhost-root" ];
  });
in
{
  ### IMPORTS ###
  imports = [
    ../modules/nixos/main-user.nix
    inputs.home-manager.nixosModules.default
    inputs.sops-nix.nixosModules.sops
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
  boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;
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

  ## keyd
  services.keyd.enable = true;

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

  # https://nixos.wiki/wiki/Sway#Systemd_services
  # https://nixos.wiki/wiki/Polkit#Authentication_agents
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    partOf = [ "graphical-session-pre.target" ];
    wantedBy = [ "graphical-session-pre.target" ];
  };

  ## Keyring
  services.gnome.gnome-keyring.enable = true;

  # Doesn't work from home manager yet, but copying the systemd unit from it:
  # https://github.com/nix-community/home-manager/blob/0a7ffb28e5df5844d0e8039c9833d7075cdee792/modules/services/gnome-keyring.nix#L41-L58
  systemd.user.services.gnome-keyring = {
    description = "GNOME Keyring";
    serviceConfig = {
        Type = "simple";
        # Note: `${pkgs.gnome.gnome-keyring}/bin/gnome-keyring-daemon` doesn't work and results in
        #`no process capabilities, insecure memory might get used` error.
        # `/run/wrappers/bin/gnome-keyring-daemon` works and has `cap_ipc_lock=ep`.
        # https://github.com/NixOS/nixpkgs/blob/683aa7c4e385509ca651d49eeb35e58c7a1baad6/nixos/modules/services/desktops/gnome/gnome-keyring.nix#L44-L49
        # https://github.com/NixOS/nixpkgs/blob/683aa7c4e385509ca651d49eeb35e58c7a1baad6/pkgs/desktops/gnome/core/gnome-keyring/default.nix#L85-L93
        #
        # We're also using the ssh-agent from gcr instead of gnome-keyring.
        ExecStart = "/run/wrappers/bin/gnome-keyring-daemon --start --foreground --components=\"pkcs11,secrets\" --control-directory=\"%t/keyring\"";
        Restart = "on-abort";
      };
    partOf = [ "graphical-session-pre.target" ];
    wantedBy = [ "graphical-session-pre.target" ];
  };

  # https://gitlab.gnome.org/GNOME/gcr/-/blob/78e5f89016635b4c4922e63f599b8ec81ea4b923/gcr/gcr-ssh-agent.service.in
  systemd.user.services.gcr-ssh-agent = {
    description = "GCR ssh-agent wrapper";
    requires = [ "gcr-ssh-agent.socket" ];
    serviceConfig = {
        Type = "simple";
        StandardError = "journal";
        Environment = "SSH_AUTH_SOCK=%t/gcr/ssh";
        ExecStart = "${gcr-with-ssh}/libexec/gcr-ssh-agent --base-dir %t/gcr";
        Restart = "on-failure";
      };
    wantedBy = [ "default.target" ];
  };

  # https://gitlab.gnome.org/GNOME/gcr/-/blob/78e5f89016635b4c4922e63f599b8ec81ea4b923/gcr/gcr-ssh-agent.socket.in
  systemd.user.sockets.gcr-ssh-agent = {
    description = "GCR ssh-agent wrapper";
    socketConfig = {
      Priority = 6;
      Backlog = 5;
      ListenStream = "%t/gcr/ssh";
      ExecStartPost= "-@systemctl@ --user set-environment SSH_AUTH_SOCK=%t/gcr/ssh";
      DirectoryMode = 0700;
    };
    wantedBy = [ "sockets.target" ];
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
    nix-search-cli
    tlp
    keyd

    # Enable automounting USB/drives
    udisks
    udiskie
    usbutils
    # GParted
    my-gparted-with-xhost-root
    xorg.xhost

    # Polkit
    polkit_gnome

    # Keyring
    gcr-with-ssh

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
    etc."keyd/default.conf".text = keydConfig;
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
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
