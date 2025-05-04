{
  pkgs,
  backrest,
  rclone,
  restic,
  rustic,
  testdisk-qt,
  ...
}:
{
  _module.args = {
    # Rustic support in Backrest
    # https://github.com/rustic-rs/rustic/discussions/1160
    backrest = pkgs.backrest;
    rclone = pkgs.rclone;
    restic = pkgs.restic;
    rustic = pkgs.rustic-rs;
    testdisk-qt = pkgs.testdisk-qt;
  };

  home.packages = [
    backrest
    rclone
    restic
    rustic
    testdisk-qt
  ];
}
