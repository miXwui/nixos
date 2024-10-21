{ pkgs, foot, ...}:

let
  #catppuccinDrv = pkgs.fetchurl {
  #  # https://www.reddit.com/r/Nix/comments/17o6698/foot_configuration_in_homemanager_importing_a/ — thanks!
  #  url = "https://raw.githubusercontent.com/catppuccin/foot/009cd57bd3491c65bb718a269951719f94224eb7/catppuccin-mocha.conf";
  #  hash = "sha256-plQ6Vge6DDLj7cBID+DRNv4b8ysadU2Lnyeemus9nx8=";
  #};
in {
  _module.args = {
    foot = pkgs.unstable.foot;
  };

  programs.foot = {
    enable = true;
    package = foot;
    settings = {
      # https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
      main = {
        #include = "${catppuccinDrv}";

        font = "Cascadia Mono:size=13";
      };

      scrollback = {
        lines = 5000; # default: 1000
      };

      key-bindings = {
        # https://codeberg.org/dnkl/foot/issues/1264#issuecomment-1839328
        pipe-scrollback = "[sh -c 'cat> /tmp/foot-terminal-scrollback ; foot hx /tmp/foot-terminal-scrollback'] Control+Shift+s";
      };

      # kitty theme, but brighter colors changed pastel
      # using one color left on the monochromatic color scale
      # on https://www.colorhexa.com/cc0403
      cursor = {
        color = "1e1e1e d9d9d9";  # 111111 cccccc
      };

      colors = {
        foreground = "eaeaea"; #dddddd # light gray
        background = "0d0d0d"; #000000 # black
        regular0 = "0d0d0d"; #000000   # black
        regular1 = "b30403"; #cc0403   # red
        regular2 = "16b200"; #19cb00   # green
        regular3 = "b5b200"; #cecb00   # yellow
        regular4 = "0b65b4"; #0d73cc   # blue
        regular5 = "b51bbb"; #cb1ed1   # magenta
        regular6 = "0bb5b5"; #0dcdcd   # cyan
        regular7 = "d0d0d0"; #dddddd   # white
        bright0 = "696969"; #767676    # bright black
        bright1 = "ea0f0e"; #f2201f    # bright red
        bright2 = "1fe400"; #23fd00    # bright green
        bright3 = "e6e400"; #fffd00    # bright yellow
        bright4 = "0083ff"; #1a8fff    # bright blue
        bright5 = "fd0fff"; #fd28ff    # bright magenta
        bright6 = "00fafa"; #14ffff    # bright cyan
        bright7 = "f2f2f2"; #ffffff    # bright white
      };
    };
  };
}
