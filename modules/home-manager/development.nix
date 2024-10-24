{
  config,
  pkgs,
  filezilla,
  zellij,
  ...
}:
let
  # Build latest unreleased Zellij that uses `rustPlatform.buildRustPackage`.
  zellij-unreleased = pkgs.zellij.overrideAttrs (old: {
    # Fetch latest `Cargo.lock` from the main branch.
    # `url` can be pinned to another branch/ref/tag
    # See: TODO.
    cargoDeps = pkgs.rustPlatform.importCargoLock {
      lockFile = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/zellij-org/zellij/main/Cargo.lock";
        sha256 = "sha256:0fbd53250pcn0pcv7zbphmcvda879637fiqhvwmxlk45rmwwbbf4";
      };
    };

    # Pin/fetch commit to build.
    src = pkgs.fetchFromGitHub {
      owner = "zellij-org";
      repo = "zellij";
      rev = "47caeb66a6c5b8b229c1227ce823defcdccf31b8";
      sha256 = "sha256-fkyi5iIZEZXPq6a4qn3xS88qgecN3gZLLv00PoTVDlA=";
    };
  });
in
{
  _module.args = {
    filezilla = pkgs.filezilla;
    # zellij = pkgs.zellij;
    zellij = zellij-unreleased;

  };

  home.packages = [
    filezilla
    zellij
  ];

  home.file = {
    "${config.xdg.configHome}/zellij" = {
      source = ../../home/.config/zellij;
      recursive = true;
    };
  };
}
