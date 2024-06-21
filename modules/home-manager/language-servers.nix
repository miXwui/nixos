{ pkgs, unstable,
  lexical,
  nil,
... }:

{
  _module.args = {
    lexical = unstable.lexical;
    nil = unstable.nil;
  };

  home.packages = [
    lexical
    nil
  ];
}
