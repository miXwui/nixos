{ config, pkgs, inputs, sway, sops, ... }:
let
  ### Unstable packages
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  ### MODULE ARGS ###
  # Project wide args to use e.g. `{ unstable, ... }`
  # https://nix-community.github.io/home-manager/options.xhtml#opt-_module.args
  _module.args = {
    unstable = unstable;
    sway = sway;
    sops = sops;
  };

  ### IMPORTS ###
  imports = [ ../modules/home-manager ];

  ### EXTRA ###
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  nixpkgs.config.allowUnfree = true;

  ### USER ###
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mwu";
  home.homeDirectory = "/home/mwu";

  ### SESSION VARIABLES ###
  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/mwu/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";

    ## Enable Ozone Wayland support in Chromium and Electron based applications
    # https://nixos.wiki/wiki/Wayland#Electron_and_Chromium
    NIXOS_OZONE_WL = "1";

    ## Elixir/Erlang
    # Enable history in IEX
    ERL_AFLAGS = "-kernel shell_history enabled";

    # Build Erlang docs with asdf
    # https://github.com/asdf-vm/asdf-erlang?tab=readme-ov-file#getting-erlang-documentation
    KERL_BUILD_DOCS = "yes";
    KERL_DOC_TARGETS = "man html pdf chunks";
    KERL_INSTALL_HTMLDOCS = "yes";
    KERL_INSTALL_MANPAGES = "yes";
  };

  ### SHELL ALIASES ###
  home.shellAliases = {
    sl = "sl -e";
    ga = "git add";
    gc = "git commit";
    gco = "git checkout";
    gcp = "git cherry-pick";
    gl = "git prettylog";
    gp = "git push";
    gs = "git status";
    gt = "git tag";
  };

  ### HOME FILES ###
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    # Wireshark
    "${config.xdg.configHome}/wireshark" = {
      source = ../home/.config/wireshark;
      recursive = true;
    };
  };

  ### THEMES ###
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme = {
      name = "adwaita";
    };
    style = {
      name = "adwaita-dark";
    };
  };

  ### XDG ###
  # ~/.config/mimeapps.list
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
      download = "${config.home.homeDirectory}/tmp";
      documents = "${config.home.homeDirectory}/documents";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      videos =  "${config.home.homeDirectory}/videos";
      desktop = "${config.home.homeDirectory}/desktop";
      templates = "${config.home.homeDirectory}/templates";
      publicShare = "${config.home.homeDirectory}/public";
      extraConfig = {
        XDG_NIXOS_DIR = "${config.home.homeDirectory}/nixos";
        # Prioritize using `config.xdg.configHome` where possible.
        # This is not currently set by default in NixOS, see:
        # https://github.com/NixOS/nixpkgs/issues/224525
        XDG_CONFIG_HOME = "${config.xdg.configHome}";
        XDG_PROJECTS_DIR = "${config.home.homeDirectory}/projects";
        XDG_GIT_CLONES_DIR = "${config.home.homeDirectory}/projects/git-clones";
        XDG_SCRIPTS_DIR = "${config.home.homeDirectory}/projects/scripts";
        XDG_TMP_DIR = "${config.home.homeDirectory}/tmp";
        XDG_WALLPAPERS_DIR = "${config.home.homeDirectory}/pictures/wallpapers";
      };
    };
  
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = [ "firefox-private.desktop" ];
        "x-scheme-handler/https" = [ "firefox-private.desktop" ];
        "x-scheme-handler/chrome" = [ "firefox-private.desktop" ];
        "text/html" = [ "firefox-private.desktop" ];
        "application/x-extension-htm" = [ "firefox-private.desktop" ];
        "application/x-extension-html" = [ "firefox-private.desktop" ];
        "application/x-extension-shtml" = [ "firefox-private.desktop" ];
        "application/xhtml+xml" = [ "firefox-private.desktop" ];
        "application/x-extension-xhtml" = [ "firefox-private.desktop" ];
        "application/x-extension-xht" = [ "firefox-private.desktop" ];
        "video/mp4" = [ "mpv.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" ];
        "video/quicktime" = [ "mpv.desktop" ];
        "image/*" = [ "org.gnome.Loupe.desktop" ];
        "application/x-bittorrent" = [ "qBitorrent.desktop" ];
      };
      associations.added = {
        "x-scheme-handler/http" = [ "firefox-private.desktop" ];
        "x-scheme-handler/https" = [ "firefox-private.desktop" ];
        "x-scheme-handler/chrome" = [ "firefox-private.desktop" ];
        "text/html" = [ "firefox-private.desktop" ];
        "application/x-extension-htm" = [ "firefox-private.desktop" ];
        "application/x-extension-html" = [ "firefox-private.desktop" ];
        "application/x-extension-shtml" = [ "firefox-private.desktop" ];
        "application/xhtml+xml" = [ "firefox-private.desktop" ];
        "application/x-extension-xhtml" = [ "firefox-private.desktop" ];
        "application/x-extension-xht" = [ "firefox-private.desktop" ];
        "video/mp4" = [ "mpv.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" ];
        "video/quicktime" = [ "mpv.desktop" ];
        "image/*" = [ "org.gnome.Loupe.desktop" ];
        "application/x-bittorrent" = [ "qBitorrent.desktop" ];
      };
    };
  };

  ### PACKAGES ###
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    # Desktop environment
    kanshi
    ulauncher # TODO: remove
    networkmanagerapplet
    blueman
    # File managers
    gnome.nautilus
    cinnamon.nemo-with-extensions
    kdePackages.dolphin
    xfce.thunar
    spacedrive

    # Camera
    snapshot

    # CLI utilities
    htop
    jq
    wget
    bc
    units
    # GUI utilities
    gnome.zenity # requirement for scripts using zenity

    # Editors
    vim
    unstable.vscode
    unstable.helix

    zeal

    # Terminal
    tmux
    tree
    sl

    # Power management
    powertop
    powerstat

    # Programs
    unstable.firefox
    unstable.chromium
  ];

  home.activation = {
    # Scripts to run during the activation phase.
    # createMyDir = '' '';
  };

  ### MISCELLANEOUS ###
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
