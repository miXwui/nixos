# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, ... }:
let
  tlpConfig = builtins.readFile ../etc/tlp.conf;
  keydConfig = builtins.readFile ../etc/keyd/default.conf;

  my-gparted-with-xhost-root = pkgs.gparted.overrideAttrs (previousAttrs: {
    configureFlags = previousAttrs.configureFlags ++ [ "--enable-xhost-root" ];
  });
in
{
  imports =
    [
      ../modules/nixos/main-user.nix
      inputs.home-manager.nixosModules.default
    ]; 

  # https://nixos.wiki/wiki/Linux_kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;
  boot.supportedFilesystems = [ "bcachefs" ];

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

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
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

  # Enable automounting USB/drives
  services.gvfs.enable = true; 
  services.udisks2.enable = true;

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

  # Enable sound with pipewire.
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

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  main-user.enable = true;
  main-user.username = "mwu";
  main-user.fullname = "Michael Wu";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Enable SDDM
  services.displayManager = {
    sddm.enable = true;
    sddm.wayland.enable = true;
    sessionPackages = [ pkgs.sway ];
  };

  # Polkit
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

  systemd = {
    # https://nixos.wiki/wiki/Sway#Systemd_services
    # https://nixos.wiki/wiki/Polkit#Authentication_agents
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
    };
  };

  # PAM
  # https://nixos.wiki/wiki/Sway#Swaylock_cannot_be_unlocked_with_the_correct_password
  # https://github.com/swaywm/sway/issues/2773#issuecomment-427570877
  security.pam.services.swaylock = {
    text = ''
      #
      # PAM configuration file for the swaylock screen locker. By default, it includes
      # the 'login' configuration file (see /etc/pam.d/login)
      #

      auth            sufficient      pam_unix.so try_first_pass likeauth nullok
      auth            sufficient      pam_fprintd.so
      #auth           include         login
    '';
  };

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = { inherit inputs; };
    users = {
      "mwu" = import ./home.nix;
    };
    backupFileExtension = "nixbak";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    variables = {
      # Enable history in IEX
      ERL_AFLAGS = "-kernel shell_history enabled";

      # Build Erlang docs with asdf
      # https://github.com/asdf-vm/asdf-erlang?tab=readme-ov-file#getting-erlang-documentation
      KERL_BUILD_DOCS = "yes";
      KERL_DOC_TARGETS = "man html pdf chunks";
      KERL_INSTALL_HTMLDOCS = "yes";
      KERL_INSTALL_MANPAGES = "yes";
    };

    shellAliases = {
      sl = "sl -e";
      gl = "git log";
      gs = "git status";
    };

    systemPackages = with pkgs; [
      #vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.

      # Utilities
      keyd
      nix-search-cli
      tlp

      # Enable automounting USB/drives
      udisks
      udiskie
      usbutils
      # GParted
      my-gparted-with-xhost-root
      xorg.xhost

      # Polkit
      polkit_gnome

      # Audio
      pavucontrol
      helvum

      # audit
      # btrfs-assistant

      # firewalld-gui
    ];

    etc."tlp.conf".text = tlpConfig;
    etc."keyd/default.conf".text = keydConfig;
  };

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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.light.enable = true;
  programs.fish.enable = true;
  programs.dconf.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # https://www.reddit.com/r/NixOS/comments/16mbn41/install_but_dont_enable_openssh_sshd_service/
  # This adds systemd.services.sshd to the config and automatically enables it:
  services.openssh.enable = true;
  # so we disable automatic start up here:
  systemd.services.sshd.wantedBy = lib.mkForce [ ];

  services.tlp.enable = true;
  services.keyd.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
