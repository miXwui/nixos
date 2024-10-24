{
  config,
  pkgs,

  scls,
  efm-ls,

  lexical,

  nil,
  nixfmt,

  deno,
  vscode-langservers-extracted,
  marksman,
  markdownlint-cli2,
  markdownlint-cli,
  ...
}:
{
  _module.args = {
    # simple-completion-language-server
    scls =
      (builtins.getFlake "github:estin/simple-completion-language-server/49b53f63f588765abfcebb59cfc2889170c2e42b")
      .defaultPackage.${pkgs.system};

    # efm-langserver
    efm-ls = pkgs.efm-langserver;

    # Elixir
    lexical =
      (builtins.getFlake "github:lexical-lsp/lexical/6e189c807cc1ff0f5c1ceec2990b541364bccb4a")
      .packages.${pkgs.system}.default;

    # Nix
    nil = pkgs.nil;
    nixfmt = pkgs.nixfmt-rfc-style;

    deno = pkgs.deno;
    vscode-langservers-extracted = pkgs.vscode-langservers-extracted;
    marksman = pkgs.marksman;
    markdownlint-cli2 = pkgs.markdownlint-cli2;
    markdownlint-cli = pkgs.markdownlint-cli;
  };

  home.packages = [
    scls
    efm-ls

    lexical

    nil
    nixfmt

    deno
    vscode-langservers-extracted
    marksman
    markdownlint-cli2
    markdownlint-cli
  ];

  home.file = {
    "${config.xdg.configHome}/efm-langserver" = {
      source = ../../home/.config/efm-langserver;
      recursive = true;
    };
  };
}
