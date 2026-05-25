{
  config,
  pkgs,
  inputs,
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

  # Go
  gopls,
  golangci-lint-langserver,
  delve,

  # HTML
  superhtml,
  emmet-language-server,

  # Lua
  lua-language-server,

  # Markdown Preview Language Server
  mpls,
  
  # Nix
  nil,
  nixfmt,

  # Python
  ruff,

  # JavaScript/TypeScript
  biome,
  deno,
  typescript-language-server,
  vtsls,

  vscode-langservers-extracted,
  marksman,
  markdownlint-cli2,
  markdownlint-cli,

  # YAML
  yaml-language-server,
  yamlfmt,

  # TOML
  tombi,
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
    expert = inputs.expert.packages.${pkgs.system}.default;

    # Go
    gopls = pkgs.gopls;
    golangci-lint-langserver = pkgs.golangci-lint-langserver;
    delve = pkgs.delve;

    # HTML
    superhtml = pkgs.superhtml;
    emmet-language-server = pkgs.emmet-language-server;

    # Lua
    lua-language-server = pkgs.lua-language-server;

    # Markdown Preview Language Server
    mpls = pkgs.mpls;

    # Nix
    nil = pkgs.nil;
    nixfmt = pkgs.nixfmt-rfc-style;

    # Python
    ruff = pkgs.ruff;

    # JavaScript/TypeScript
    biome = pkgs.biome;
    deno = pkgs.deno;
    typescript-language-server = pkgs.typescript-language-server;
    vtsls = pkgs.vtsls;

    # Markdown
    marksman = pkgs.marksman;
    markdownlint-cli2 = pkgs.markdownlint-cli2;
    markdownlint-cli = pkgs.markdownlint-cli;

    # YAML
    yaml-language-server = pkgs.yaml-language-server;
    yamlfmt = pkgs.yamlfmt;

    # TOML
    tombi = pkgs.tombi;
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

    # Go
    gopls
    golangci-lint-langserver
    delve

    # HTML
    superhtml
    emmet-language-server

    # Lua
    lua-language-server

    # Markdown Preview Language Server
    mpls
    
    # Nix
    nil
    nixfmt

    # Python
    ruff

    # JavaScript/TypeScript
    biome
    deno
    typescript-language-server
    vtsls

    # Markdown
    marksman
    markdownlint-cli2
    markdownlint-cli

    # YAML
    yaml-language-server
    yamlfmt

    # TOML
    tombi
  ];

  home.file = {
    "${config.xdg.configHome}/efm-langserver".source =
      config.lib.file.mkOutOfStoreSymlink "${xdg_nixos.userConfigDir}/efm-langserver";
  };
}
