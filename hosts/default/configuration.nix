# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/nixos/main-user.nix
      inputs.home-manager.nixosModules.default
    ]; 

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  boot.loader.grub.enableCryptodisk=true;

  boot.initrd.luks.devices."luks-4f95a8c6-4383-457b-ac3a-22f3657e9971".keyFile = "/crypto_keyfile.bin";

  # https://nixos.wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

#  # Enable CUPS to print documents.
#  services.printing = {
#    enable = true;
#    drivers = [];
#  }

  # Enable sound with pipewire.
#  sound.enable = true;
#  hardware.pulseaudio.enable = false;
#  security.rtkit.enable = true;
#  services.pipewire = {
#    enable = true;
#    alsa.enable = true;
#    alsa.support32Bit = true;
#    pulse.enable = true;
#  };

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

  # https://nixos.wiki/wiki/Sway#Using_Home_Manager
  security.polkit.enable = true;

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

      # QT_QPA_PLATFORMTHEME =  "gnome";
    };

    shellAliases = {
      sl = "sl -e";
      gl = "git log";
      gs = "git status";
    };

    systemPackages = with pkgs; [
      #vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    ];
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
  programs.fish.enable = true;
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
