{ pkgs, ... }:
let
  # Needs bsddb3 for `bitcoin2john.py`.
  # See: https://github.com/openwall/john/issues/4143
  # TODO: PR to nixpkgs?
  john_with-bsddb3 = pkgs.john.overrideAttrs (previousAttrs: {
    propagatedBuildInputs = previousAttrs.propagatedBuildInputs ++ [
      (pkgs.python3.withPackages (ps: with ps; [ bsddb3 ]))
    ];
  });
in
{
  _module.args = {
    john = john_with-bsddb3;
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
