{
  config,
  pkgs,
  xdg_nixos_dir,
  sway,
  sops,
  gProgs,
  xdg-utils,
  ...
}:
let
  # Dirs
  xdg_nixos = rec {
    rootDir = xdg_nixos_dir;
    userConfigDir = "${rootDir}/home/.config";
    scriptsDir = "${rootDir}/scripts";
  };

  # GProgs
  coreutils = gProgs.coreutils;
  logger = gProgs.logger;
  playerctl = gProgs.playerctl;
in
{
  ### MODULE ARGS ###
  # Project wide args to use e.g. `{ sway, ... }`
  # https://nix-community.github.io/home-manager/options.xhtml#opt-_module.args
  _module.args = {
    # Dirs
    xdg_nixos = xdg_nixos;

    # Sway
    sway = sway;

    # Global programs
    coreutils = coreutils;
    logger = logger;
    playerctl = playerctl;

    # sops
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
    EDITOR = "hx";

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
    # Git
    ga = "git add";
    gb = "git branch";
    gc = "git commit";
    gco = "git checkout";
    gcp = "git cherry-pick";
    gl = "git prettylog";
    gp = "git push";
    gs = "git status";
    gt = "git tag";

    # Zellij
    zj = "zellij";
    zjw = "zellij -l welcome";
    zjl = "zellij -l";
    zjll = "zellij -l layout.kdl";
    zrf = "zellij run --floating";
    ze = "zellij edit";
    zri = "zellij run --in-place";
    zpipe = "zellij pipe -p";
    zpf = "zellij pipe -p filepicker";

    # Misc
    dfs = "$XDG_SCRIPTS_DIR/diff-so-fancy.sh";
    nb = "numbat";
    wlc = "wl-copy";
    yidle = "${config.xdg.configHome}/sway/scripts/get-idle-inhibitors.sh";

    sl = "sl -e";
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

    # Use `mkOutOfStoreSymlink` where possible to symlink to files/folders in
    # this NixOS project folder. This allows editing files without needing to
    # rebuild.
    # See: https://github.com/nix-community/home-manager/issues/2085
    #
    # Some places use still need to use `home.file.<filepath>` because e.g.
    # some string needs to be substituted in the text. And so since it requires
    # a rebuild, there's no point to symlink to the files/folders in this NixOS
    # folder.

    # Wireshark
    "${config.xdg.configHome}/wireshark".source = config.lib.file.mkOutOfStoreSymlink "${xdg_nixos.userConfigDir}/wireshark";
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
      package = pkgs.gnome-themes-extra;
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
      videos = "${config.home.homeDirectory}/videos";
      desktop = "${config.home.homeDirectory}/desktop";
      templates = "${config.home.homeDirectory}/templates";
      publicShare = "${config.home.homeDirectory}/public";
      extraConfig = {
        XDG_NIXOS_DIR = "${xdg_nixos_dir}";
        # Prioritize using `config.xdg.configHome` where possible.
        # This is not currently set by default in NixOS, see:
        # https://github.com/NixOS/nixpkgs/issues/224525
        XDG_CONFIG_HOME = "${config.xdg.configHome}";
        XDG_PROJECTS_DIR = "${config.home.homeDirectory}/projects";
        XDG_GIT_CLONES_DIR = "${config.home.homeDirectory}/projects/git-clones";
        XDG_SCRIPTS_DIR = "${xdg_nixos.scriptsDir}";
        XDG_TMP_DIR = "${config.home.homeDirectory}/tmp";
        XDG_WALLPAPERS_DIR = "${config.home.homeDirectory}/pictures/wallpapers";
      };
    };

    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = config.mime.defaults;
      associations.added = config.mime.defaults;
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

    ntfs3g
    exfat
    gptfdisk
    btrfs-progs
    compsize
    # fuse3
    gnome-disk-utility
    parted

    gnumake

    rustc
    rustup
    gcc

    elixir_1_18
    erlang_27

    # python3
    (python3.withPackages (
      ps: with ps; [
        pip
      ]
    ))

    # Desktop environment
    kanshi
    networkmanagerapplet
    blueman

    # Fonts
    gnome-font-viewer

    # smile
    emote

    ollama
    # open-webui # commented because it fails/prevents build

    # Camera
    snapshot

    # Images
    loupe

    # CLI utilities
    htop
    jq
    wget
    bc
    units
    numbat
    killall
    bat
    ripgrep
    fd

    pciutils # lspci, etc.

    nix-search-cli

    ncdu
    rdfind
    fclones

    speedcrunch

    s-tui
    stress
    speedtest-cli

    # GUI utilities
    zenity # requirement for scripts using zenity

    zeal

    # Terminal
    tmux
    tree
    sl

    # Programs
    firefox
    chromium

    fw-ectool
  ];

  home.activation = {
    # Scripts to run during the activation phase.
    # createMyDir = '' '';
    # removeFolder = ''
    #   rm -rf /path/to/something
    # '';
  };

  ### SERVICES ###
  services = {
    udiskie = {
      enable = true;
      automount = false;
      notify = true;
      tray = "auto";
      # NOTE: Fixes `Can't find file browser: 'xdg-open'` for `udiskie`.
      # See: https://github.com/nix-community/home-manager/issues/632#issuecomment-2210425312
      settings = {
        program_options = {
          file_manager = "${xdg-utils}/bin/xdg-open";
          # file_manager = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.yazi}/bin/yazi";
        };
      };
      # /endfix
    };

    # mpd = {
    #   enable = true;
    #   musicDirectory = ;
    # }
  };

  # NOTE: Fixes `Unit tray.target not found` for `udiskie`.
  # See: https://github.com/nix-community/home-manager/issues/2064#issuecomment-887300055
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };
  # /endfix

  ### MISCELLANEOUS ###
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
