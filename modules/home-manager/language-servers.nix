{
  config,
  pkgs,
  xdg_nixos,

  # General
  dprint,
  ispell,
  efm-ls,
  scls,

  # Bash
  bash-language-server,
  shellcheck,
  shfmt,

  # Elixir
  expert,

  # HTML
  superhtml,
  emmet-language-server,

  # Nix
  nil,
  nixfmt,

  # JavaScript/TypeScript
  typescript-language-server,

  deno,
  vscode-langservers-extracted,
  marksman,
  markdownlint-cli2,
  markdownlint-cli,

  # YAML
  yaml-language-server,
  yamlfmt,

  ...
}:
{
  _module.args = {
    # General
    efm-ls = pkgs.efm-langserver;
    dprint = pkgs.dprint;
    ispell = pkgs.ispell;
    scls =
      (builtins.getFlake "github:estin/simple-completion-language-server/49b53f63f588765abfcebb59cfc2889170c2e42b")
      .defaultPackage.${pkgs.system}; # simple-completion-language-server
    vscode-langservers-extracted = pkgs.vscode-langservers-extracted;

    # Bash
    bash-language-server = pkgs.bash-language-server;
    shellcheck = pkgs.shellcheck;
    shfmt = pkgs.shfmt;

    # Elixir
    expert =
      (builtins.getFlake "github:elixir-lang/expert/86fe8ec2168c266631e7f3506fcbf0afa6083656")
      .packages.${pkgs.system}.expert;

    # HTML
    superhtml = pkgs.superhtml;
    emmet-language-server = pkgs.emmet-language-server;

    # Nix
    nil = pkgs.nil;
    nixfmt = pkgs.nixfmt-rfc-style;


    # JavaScript/TypeScript
    deno = pkgs.deno;
    typescript-language-server = pkgs.typescript-language-server;

    # Markdown
    marksman = pkgs.marksman;
    markdownlint-cli2 = pkgs.markdownlint-cli2;
    markdownlint-cli = pkgs.markdownlint-cli;

    # YAML
    yaml-language-server = pkgs.yaml-language-server;
    yamlfmt = pkgs.yamlfmt;
  };

  home.packages = [
    # General
    efm-ls
    dprint
    ispell
    scls
    vscode-langservers-extracted

    # Bash
    bash-language-server
    shellcheck
    shfmt

    # Elixir
    expert

    # HTML
    superhtml
    emmet-language-server

    # Nix
    nil
    nixfmt


    # JavaScript/TypeScript
    deno
    typescript-language-server

    # Markdown
    marksman
    markdownlint-cli2
    markdownlint-cli

    # YAML
    yaml-language-server
    yamlfmt
  ];

  home.file = {
    "${config.xdg.configHome}/efm-langserver".source =
      config.lib.file.mkOutOfStoreSymlink "${xdg_nixos.userConfigDir}/efm-langserver";
  };
}
