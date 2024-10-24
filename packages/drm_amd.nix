# Python / gobject-introspection / glib woes, packaged neatly.

# So here I fall,
# down the hole,
# where rabbits lay.

# These were helpful: 
# * https://pygobject.gnome.org/getting_started.html#arch-getting-started
# * https://discourse.nixos.org/t/python-glib-introspection-fails/47391/13
# * https://discourse.nixos.org/t/packaging-a-single-python-script-with-runtime-dependencies/31046/3
# * https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/python.section.md
# * https://github.com/Artturin/nixpkgs/blob/581b56878481bf9066571eb734faa640d08a2ff7/pkgs/applications/audio/whipper/default.nix#L43

{
  lib,
  pkgs,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "amd_s2idle_check";
  version = "0.0.1";
  pyproject = false;

  src = pkgs.fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "drm";
    repo = "amd";
    rev = "449cf64fdd71ac14893e8e9fd2eeb65ac65cdd84";
    sha256 = "sha256-87dWGeWOSOGfoeHEkOJP12Jv2f6+93iyist4vq2mTAY=";
  };

  nativeBuildInputs = with pkgs; [
    wrapGAppsNoGuiHook
    gobject-introspection
  ];

  dependencies =
    with python3Packages;
    [
      distro
      packaging
      pygobject3
      pyudev
      systemd
    ]
    ++ (with pkgs; [
      acpica-tools
      fwupd
      json-glib
    ]);

  installPhase = ''
    install -Dm755 scripts/amd_s2idle.py $out/bin/amd_s2idle
    install -Dm755 scripts/get_amdgpu_fw_version.py $out/bin/get_amdgpu_fw_version
    install -Dm755 scripts/psr.py $out/bin/psr
  '';

  meta = with lib; {
    homepage = "https://gitlab.freedesktop.org/drm/amd";
    description = "AMD DRM scripts";
    # maintainers = with maintainers; [ ];
    # license = licenses.gpl3Plus; # what license?
    platforms = platforms.linux;
  };
}
