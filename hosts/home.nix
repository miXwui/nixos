{ config, pkgs, inputs, ... }:
let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  # Project wide args to use e.g. `{ unstable, ... }`
  # https://nix-community.github.io/home-manager/options.xhtml#opt-_module.args
  _module.args = {
    unstable = unstable;
  };

  imports = [ ../modules/home-manager ];

  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mwu";
  home.homeDirectory = "/home/mwu";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
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
    unstable.sway
    swaylock
    wlogout
    unstable.waybar
    swayidle
    ulauncher # TODO: remove
    networkmanagerapplet
    blueman
    # File managers
    gnome.nautilus
    cinnamon.nemo-with-extensions
    kdePackages.dolphin
    xfce.thunar
    spacedrive

    grim
    slurp
    wl-clipboard

    gnome.zenity

    # Utilities
    git
    fish
    htop
    jq
    wget
    bc
    units

    # Editors
    vim
    unstable.vscode
    unstable.helix

    # Terminal
    unstable.contour
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

    # Write files
    "${config.xdg.configHome}/sway" = {
      source = ../home/.config/sway;
      recursive = true;
    };

    "Pictures/Wallpapers" = {
      source = ../home/Pictures/Wallpapers;
      recursive = true;
    };

    "${config.xdg.configHome}/waybar" = {
      source = ../home/.config/waybar;
      recursive = true;
    };

    ".icons/default" = {
      source = ../home/.local/share/icons/volantes_light_cursors;
      recursive = true;
    };

    "${config.xdg.configHome}/wlogout" = {
      source = ../home/.config/wlogout;
      recursive = true;
    };
  };

  # Themes
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

  # MIME
  # ~/.config/mimeapps.list 
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "x-scheme-handler/chrome" = [ "firefox.desktop" ];
    "text/html" = [ "firefox.desktop" ];
    "application/x-extension-htm" = [ "firefox.desktop" ];
    "application/x-extension-html" = [ "firefox.desktop" ];
    "application/x-extension-shtml" = [ "firefox.desktop" ];
    "application/xhtml+xml" = [ "firefox.desktop" ];
    "application/x-extension-xhtml" = [ "firefox.desktop" ];
    "application/x-extension-xht" = [ "firefox.desktop" ];
  };

  xdg.mimeApps.associations.added = {
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "x-scheme-handler/chrome" = [ "firefox.desktop" ];
    "text/html" = [ "firefox.desktop" ];
    "application/x-extension-htm" = [ "firefox.desktop" ];
    "application/x-extension-html" = [ "firefox.desktop" ];
    "application/x-extension-shtml" = [ "firefox.desktop" ];
    "application/xhtml+xml" = [ "firefox.desktop" ];
    "application/x-extension-xhtml" = [ "firefox.desktop" ];
    "application/x-extension-xht" = [ "firefox.desktop" ];
  };

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
    # TESTTEST = "$XDG_RUNTIME_DIR";
  };

  systemd.user.sessionVariables = {
    # XDG_RUNTIME_DIR = "/run/user/$(id -u)";
    # TESTTEST = "$XDG_RUNTIME_DIR";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
