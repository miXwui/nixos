{ lib, pkgs, coreutils, sops, ... }:
let
  sshKeysExist = (sops.secrets ? ssh_private_key) && (sops.secrets ? ssh_public_key);
in
{
  # Valid permissions:
  # - `chmod 600 ~/.ssh/id_edXXXXX`:
  # - `chmod 644 ~/.ssh/id_edXXXXX.pub`:

  systemd.user.services.ssh-config = lib.mkIf sshKeysExist {
    Unit = {
      Description = "Write ssh keys to ~/.ssh/";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.writeScript "write-ssh-keys" ''
        #!/run/current-system/sw/bin/bash
        ${coreutils}/bin/mkdir -p ~/.ssh
        ${coreutils}/bin/cat ${sops.secrets.ssh_private_key.path} > ~/.ssh/framenix
        ${coreutils}/bin/chmod 600 ~/.ssh/framenix
        ${coreutils}/bin/cat ${sops.secrets.ssh_public_key.path} > ~/.ssh/framenix.pub
        ${coreutils}/bin/chmod 644 ~/.ssh/framenix.pub
      ''}";
    };
  };
}
