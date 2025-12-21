{
  pkgs,

  grim,
  slurp,
  swappy,
  wf-recorder,
  wl-clipboard,
  xdg-utils,
  ...
}:

{
  _module.args = {
    grim = pkgs.grim;
    slurp = pkgs.slurp;
    swappy = pkgs.swappy;
    wf-recorder = pkgs.wf-recorder;
    # `bitwarden-desktop` needs `wl-clipboard-rs`:
    # https://github.com/bitwarden/clients/pull/7508/files
    # https://github.com/1Password/arboard/issues/98#issuecomment-1461267806
    # https://github.com/1Password/arboard/blob/91c33159b019b636f0a0419557d5d736196f9681/Cargo.toml#L26C26-L26C41
    wl-clipboard = pkgs.wl-clipboard-rs;
    xdg-utils = pkgs.xdg-utils;
  };

  home.packages = [
    grim
    slurp
    swappy
    wf-recorder
    wl-clipboard
    # TODO: clipboard history
    xdg-utils
  ];
}
