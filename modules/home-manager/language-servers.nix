  lexical,
  nil,
... }:

{
  _module.args = {
    lexical = pkgs.unstable.lexical;
    nil = pkgs.unstable.nil;
  };

  home.packages = [
    lexical
    nil
  ];
}
