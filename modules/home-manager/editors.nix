{
  config,
  pkgs,

  helix,

  emacs,
  emacs-lsp-booster,

  nerdfonts,
  pandoc,
  shellcheck,
  ispell,

  neovim,
  vim,
  micro,
  sublime,
  vscode,
  zed-editor,

  meld,
  kdiff3,
  difftastic,
  gitu,
  lazygit,

  diffutils,
  diff-so-fancy,

  glow,
  inlyne,

  libreoffice,
  onlyoffice,
  xournalpp,
  ...
}:
# let
  ########################################
  # Emacs, oh Emacs.
  #
  # I'm glad to have met you,
  # but I think I've found the keeper.
  #
  # I'll keep you here to check up on you and see how you're doing.
  # You and your community have some of, if not the best ideas.
  #
  # So long, and thanks for all the memories.
  # 
  # https://github.com/nix-community/emacs-overlay
  # https://github.com/nix-community/emacs-overlay/issues/299
  # https://github.com/nix-community/emacs-overlay/blob/master/overlays/emacs.nix
  # https://github.com/emacs-mirror/emacs/commit/9b426e15abd320f9c53692bb6f5834967e6e1a37
  # emacs-30-pgtk = pkgs.emacs-pgtk.overrideAttrs ( old: {
  #   src = pkgs.fetchFromGitHub {
  #    owner = "emacs-mirror";
  #    repo = "emacs";
  #    rev = "9b426e15abd320f9c53692bb6f5834967e6e1a37";
  #    sha256 = "sha256-wnEJI0pwqgqyyPkbplZC5u5aM79LEZreoAPGAAGpsU4=";
  #   };
  # });
  # services.emacs.package = emacs-30-pgtk;
  # services.emacs.enable = true; # daemon/server mode
# in
{
  _module.args = {
    # Helix
    # Panic handler, that saves unsaved work to temporary files:
    # - https://github.com/helix-editor/helix/issues/290
    # Vim-like Persistent Undo:
    # - https://github.com/helix-editor/helix/pull/9154
    # Persistent State (session):
    # - https://github.com/helix-editor/helix/issues/401
    # Persistent state:
    # - https://github.com/helix-editor/helix/pull/9143
    # Show match index and number of matches when searching
    # - https://github.com/helix-editor/helix/issues/2811
    # [WIP] View based refactoring in workspace
    # - https://github.com/helix-editor/helix/pull/4381
    # paste from yank buffer history similar to emacs kill-ring
    # - https://github.com/helix-editor/helix/issues/6900
    # sh command substitutions
    # - https://github.com/helix-editor/helix/issues/3134
    # - https://github.com/helix-editor/helix/pull/11164
    helix =
      (builtins.getFlake "github:helix-editor/helix/0a4432b104099534f7a25b8ea4148234db146ab6")
      .packages.${pkgs.system}.default;

    emacs = pkgs.unstable.emacs29-pgtk; # can uncomment/use emacs-30-pgtk above
    emacs-lsp-booster = pkgs.unstable.emacs-lsp-booster;

    nerdfonts = pkgs.nerdfonts;
    pandoc = pkgs.pandoc;
    shellcheck = pkgs.shellcheck;
    ispell = pkgs.ispell;

    neovim = pkgs.unstable.neovim;
    vim = pkgs.vim;
    micro = pkgs.unstable.micro;
    sublime = pkgs.sublime4;
    vscode = pkgs.unstable.vscode;

    # - [Language server agnostic snippets](https://github.com/zed-industries/zed/issues/4611)
    # - [Add commands to select function, class, block, etc.](https://github.com/zed-industries/zed/issues/10799)
    # - [Remember unsaved changes](https://github.com/zed-industries/zed/issues/4683)
    # - [Language server agnostic snippets](https://github.com/zed-industries/zed/issues/4611)
    # - [Preserve untitled files for next time](https://github.com/zed-industries/zed/issues/4985)
    # - [Zed FHS](https://github.com/NixOS/nixpkgs/issues/309662#issuecomment-2155122284)
    # - https://zed.dev/docs/key-bindings

    # // Zed settings
    # //
    # // For information on how to configure Zed, see the Zed
    # // documentation: https://zed.dev/docs/configuring-zed
    # //
    # // To see all of Zed's default settings without changing your
    # // custom settings, run the `open default settings` command
    # // from the command palette or from `Zed` application menu.
    # {
    #   "project_panel": {
    #       "dock": "right"
    #   },
    #   "ui_font_size": 16,
    #   "buffer_font_size": 16,
    #   "base_keymap": "VSCode",
    #   "show_whitespaces": "all",
    #   "experimental.theme_overrides": {
    #     // Change `show_whitespaces` color
    #     "editor.invisible": "#3f3f3f"
    #   },
    #   {
    #     "languages": {
    #       "Elixir": {
    #         "path": "lexical"
    #       },
    #       "Nix": {
    #         "path": "nil",
    #       }
    #     }
    #   }
    zed-editor = pkgs.unstable.zed-editor;

    meld = pkgs.meld;
    kdiff3 = pkgs.kdiff3;
    difftastic = pkgs.difftastic;
    gitu = pkgs.unstable.gitu;
    lazygit = pkgs.unstable.lazygit;

    diffutils = pkgs.diffutils;
    diff-so-fancy = pkgs.diff-so-fancy;

    glow = pkgs.glow;
    # Fonts can appear faint / low contrast
    # - https://github.com/Inlyne-Project/inlyne/issues/102
    inlyne = pkgs.inlyne;

    libreoffice = pkgs.libreoffice;
    onlyoffice = pkgs.onlyoffice-bin;

    xournalpp = pkgs.xournalpp;
  };

  home.packages = [
    helix

    emacs
    emacs-lsp-booster
    # # For Emacs lsp-bridge
    # (pkgs.python3.withPackages(ps: with ps; [
    #   epc orjson sexpdata six setuptools paramiko rapidfuzz
    # ]))

    nerdfonts
    pandoc
    shellcheck
    ispell

    neovim
    vim
    micro
    sublime
    vscode
    zed-editor

    difftastic
    meld
    kdiff3
    gitu
    lazygit

    diffutils # required for Emacs Ediff. BusyBox's version's outdated.
    diff-so-fancy

    glow
    inlyne

    libreoffice
    onlyoffice

    xournalpp
  ];

  home.file = {
    "${config.xdg.configHome}/helix" = {
      source = ../../home/.config/helix;
      recursive = true;
    };

    "${config.xdg.configHome}/inlyne" = {
      source = ../../home/.config/inlyne;
      recursive = true;
    };
  };
}
