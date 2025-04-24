{ pkgs, john, ... }:
let
  # Needs bsddb3, but newer berkeleydb for `bitcoin2john.py` on Python 3.12?
  # See:
  # - https://github.com/openwall/john/issues/4143
  # - https://github.com/NixOS/nixpkgs/pull/311198#discussion_r1599257522
  # - https://github.com/openwall/john/commit/2778d2e9df4aa852d0bc4bfbb7b7f3dde2935b0c
  # This code might need to be updated:
  # - https://github.com/openwall/john/blob/bleeding-jumbo/run/bitcoin2john.py
  # TODO: PR to nixpkgs?
  john_with-bsddb3 = pkgs.john.overrideAttrs (previousAttrs: {
    # propagatedBuildInputs = previousAttrs.propagatedBuildInputs ++ [
    #   (pkgs.python3.withPackages (ps: with ps; [ bsddb3 ]))
    # ];
    # `bsddb3` doesn't work on Python 3.12 due to
    # https://github.com/NixOS/nixpkgs/issues/308232
    # So may need to use berkeleydb?
    # propagatedBuildInputs = previousAttrs.propagatedBuildInputs ++ [
    #   (pkgs.python3.withPackages (ps: with ps; [ berkeleydb ]))
    # ];
  });
in
{
  _module.args = {
    # john = john_with-bsddb3;
    john = pkgs.john;
  };

  home.packages = with pkgs; [
    # John the Ripper
    john

    # Bitwarden

    # Still can't copy to clipboard on Sway as of version 2024.9.0.
    bitwarden-desktop

    # Creates a `/home/mwu/.config/Bitwarden CLI` folder
    # and `/home/mwu/.config/Bitwarden CLI/data.json` file.
    bitwarden-cli

    # goldwarden
    # pinentry-all
  ];
}
