# SDDM config.

{ pkgs, lib, ... }:
let
  ### SDDM
  sddm-theme =
    (pkgs.sddm-astronaut.override {
      # /run/current-system/sw/share/sddm/themes/sddm-astronaut-theme/theme.conf
      # /run/current-system/sw/share/sddm/themes/sddm-astronaut-theme/theme.conf.user
      themeConfig = {
        # https://github.com/NixOS/nixpkgs/issues/343702#issuecomment-2391827290
        # [General]
        Background = "background.jpg"; # path relative to theme dir
        DimBackground = "0.5";
        ScreenWidth = "2256";
        ScreenHeight = "1405";

        # [Blur Settings]
        FullBlur = "true";
        BlurRadius = "50";

        # [Design Customizations]
        FormPosition = "center";
        MainColor = "#fefefe";
        AccentColor = "#0a5d69";
        PlaceholderColor = "#ed0c0c";
        OverrideTextFieldColor = "#ffffff";

        # [Locale Settings]
        HourFormat = "h:mma";
        # NOTE: For some reason using a comma `,` doesn't work, e.g.:
        # `dddd',' MMMM d yyyy`. Probably can fix somewhere in the theme's
        # code, but I don't want to spend the time to investigate atm.
        DateFormat = "dddd M/dd/yy";
      };
    }).overrideAttrs
      (old: {
        src = old.src.override {
          # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/data/themes/sddm-astronaut/default.nix
          # nixpkgs has an older version. TODO: submit a PR?
          rev = "8993670e73d36f4e8edc70d13614fa05edc2575c";
        };
      });

  # Copy background image to theme dir
  # Can also copy to Nix store and link to that:
  # https://discourse.nixos.org/t/sddm-background-on-default-theme/46263/3
  sddm-background = pkgs.stdenvNoCC.mkDerivation {
    name = "sddm-astronaut-background";
    src = builtins.path {
      path = ../../.;
      name = "nixos_root_dir";
    };

    installPhase =
      let
        basePath = "$out/share/sddm/themes/sddm-astronaut-theme";
      in
      ''
        mkdir -p ${basePath}
        cp $src/home/pictures/wallpapers/PXL_20220801_011526749.MP.jpg ${basePath}/background.jpg
      '';
  };

  # Copy custom cursors
  sddm-cursors = pkgs.stdenvNoCC.mkDerivation {
    name = "sddm-cursors";
    src = builtins.path {
      path = ../../.;
      name = "nixos_dir";
    };

    installPhase =
      let
        basePath = "$out/share/icons";
      in
      ''
        mkdir -p ${basePath}
        cp -r $src/home/.local/share/icons/volantes_light_cursors ${basePath}/volantes_light_cursors
      '';
  };
in
{
  options = {
    # SDDM themes
    # * sddm-astronaut
    # * where-is-my-sddm-theme
    # * elegant-sddm
    # * sddm-chili-theme
    # * catppuccin-sddm
    # * catppuccin-sddm-corners
    # * https://gitlab.com/Zhaith-Izaliel/sddm-sugar-candy-nix
    software_sddm.sddm-theme = lib.mkOption {
      description = "SDDM theme package.";
      default = sddm-theme;
    };

    # SDDM config
    software_sddm.config = lib.mkOption {
      description = "Settings for `services.displayManager.sddm`.";
      default = {
        # Useful:
        # * `sddm --test-mode`
        # * `sddm --example-config`
        # * `/run/current-system/sw/share/sddm/`
        # * `/run/current-system/sw/share/sddm/themes/`
        enable = true;
        # Needed to fix this error:
        # > Error: detected mismatched Qt dependencies:
        # >     /nix/store/bgfalfi93kbn8j1wfwz0x0dnk1wx9wdp-qtbase-6.8.0
        # >     /nix/store/35n2x3dnj168hd312szccii6w028syb8-qtbase-5.15.15-dev
        package = pkgs.kdePackages.sddm;
        extraPackages = with pkgs; [
          # Needed to fix this error:
          # > The current theme could not be loaded due to the errors below, please select another theme.
          # > file:///run/current-system/sw/share/sddm/themes/where_is_my_sddm_theme/Main.qml:5:1: module "Qt5Compat.GraphicalEffects" is not installed.
          kdePackages.qt5compat
          # Needed to fix this error:
          # sddm-greeter-qt6[58015]: qrc:/qt-project.org/imports/QtQuick/Controls/Fusion/RoundButton.qml: QML IconImage: Error decoding: file:///run/current-system/sw/share/sddm/themes/sddm-astronaut-theme/Assets/Reboot.svg: Unsupported image format
          # ... etc.
          # sddm-astronaut-theme's SVG icons don't show without it.
          kdePackages.qtsvg
          #   # Needed to fix this error (but not needed for `sddm-astronaut`:
          #   # The theme at "/run/current-system/sw/share/sddm/themes/Elegant" requires missing "/nix/store/nrdwzbzy7rgyqbhb76h2zlcac6zvwa8x-sddm-wrapped/bin/sddm-greeter" . Using fallback theme.
          #   libsForQt5.sddm
          # Needed to fix `module QtMultimedia is not installed` 
          kdePackages.qtmultimedia
        ];
        wayland.enable = true;
        theme = "sddm-astronaut-theme";
        # /etc/sddm.conf
        settings = {
          Theme = {
            CursorTheme = "volantes_light_cursors";
          };
        };
      };
    };

    software_sddm.sddm-background = lib.mkOption {
      description = "SDDM theme package.";
      default = sddm-background;
    };

    software_sddm.sddm-cursors = lib.mkOption {
      description = "SDDM theme package.";
      default = sddm-cursors;
    };
  };
}
