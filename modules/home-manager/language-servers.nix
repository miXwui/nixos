{
  config,
  pkgs,
  xdg_nixos,

  ispell,

  scls,
  efm-ls,

  bash-language-server,
  shellcheck,
  shfmt,

  lexical,

  nil,
  nixfmt,

  deno,
  vscode-langservers-extracted,
  marksman,
  markdownlint-cli2,
  markdownlint-cli,

  yaml-language-server,
  yamlfmt,

  ...
}:
{
  _module.args = {
    # Spelling
    ispell = pkgs.ispell;

    # simple-completion-language-server
    scls =
      (builtins.getFlake "github:estin/simple-completion-language-server/49b53f63f588765abfcebb59cfc2889170c2e42b")
      .defaultPackage.${pkgs.system};

    # efm-langserver
    efm-ls = pkgs.efm-langserver;

    # Bash
    bash-language-server = pkgs.bash-language-server;
    shellcheck = pkgs.shellcheck;
    shfmt = pkgs.shfmt;

    # Elixir
    lexical =
      (builtins.getFlake "github:lexical-lsp/lexical/477e8b418b27960710109d0014167bb371b0cade")
      .packages.${pkgs.system}.default;

    # Nix
    nil = pkgs.nil;
    nixfmt = pkgs.nixfmt-rfc-style;

    deno = pkgs.deno;
    vscode-langservers-extracted = pkgs.vscode-langservers-extracted;
    marksman = pkgs.marksman;
    markdownlint-cli2 = pkgs.markdownlint-cli2;
    markdownlint-cli = pkgs.markdownlint-cli;

    # YAML
    yaml-language-server = pkgs.yaml-language-server;
    yamlfmt = pkgs.yamlfmt;
  };

  home.packages = [
    ispell

    scls
    efm-ls

    bash-language-server
    shellcheck
    shfmt

    lexical

    nil
    nixfmt

    deno
    vscode-langservers-extracted
    marksman
    markdownlint-cli2
    markdownlint-cli

    yaml-language-server
    yamlfmt
  ];

  home.file = {
    "${config.xdg.configHome}/efm-langserver".source = config.lib.file.mkOutOfStoreSymlink "${xdg_nixos.userConfigDir}/efm-langserver";
  };
}
