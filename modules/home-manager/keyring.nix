{ pkgs, lib, seahorse, ... }:
let
  ### gcr_4
  #
  # Use gcr for ssh instead of from gnome-keyring:
  # https://gitlab.gnome.org/GNOME/gnome-keyring/-/merge_requests/60
  #
  # `gcr` package is an older version 3 that crashes:
  # https://github.com/NixOS/nixpkgs/blob/13edc842adf7e4889ab39c0703e772d4c1fa05b1/pkgs/development/libraries/gcr/default.nix#L29
  # `gcr4` exists, so we use that, and override to enable ssh-agent since it's disabled here:
  # https://github.com/NixOS/nixpkgs/blob/6c2520b3debc83b26ba56e0b47a82d79d5b50c23/pkgs/development/libraries/gcr/4.nix#L73-L75
  gcr-with-ssh = pkgs.gcr_4.overrideAttrs (previousAttrs: {
    # Add `openssh` which has the required `ssh-add`:
    nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ pkgs.openssh ];
    # Enable `ssh_agent` and `systemd`:
    # https://gitlab.gnome.org/GNOME/gcr/-/blob/78e5f89016635b4c4922e63f599b8ec81ea4b923/meson.build
    # https://gitlab.gnome.org/GNOME/gcr/-/blob/78e5f89016635b4c4922e63f599b8ec81ea4b923/meson_options.txt
    mesonFlags = lib.lists.remove "-Dssh_agent=false" previousAttrs.mesonFlags ++ [ "-Dssh_agent=true" ];
  });
in
{
  # We use a combination of GNOME Keyring for `pkcs11` and `secrets` and GNOME GCR for `ssh`.

  # Helpful article about GNOME Keyring/SSH with Sway,
  # but on Fedora (which I referred to when I was on Fedora):
  # https://major.io/p/use-gnome-keyring-with-sway/

  _module.args = {
    seahorse = pkgs.seahorse;
  };

  home.packages = [
    seahorse
  ];

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
  };

  # Apparently gnome-keyring doesn't work from home-manager yet:
  # https://github.com/nix-community/home-manager/issues/1454

  # services.gnome-keyring = {
  #   enable = true;
  #   components = ["pkcs11" "secrets"];
  # };

  # so we enable it to `hosts/base.nix`.

  # Create the systemd user services manually, since it's not created when gnome-keyring is enabled outside of home-manager:
  # https://github.com/nix-community/home-manager/blob/0a7ffb28e5df5844d0e8039c9833d7075cdee792/modules/services/gnome-keyring.nix#L41-L58
  systemd.user.services.gnome-keyring = {
    Unit = {
      Description = "GNOME Keyring";
      PartOf = [ "graphical-session-pre.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session-pre.target" ];
    };
    Service = {
      Type = "simple";
        # Note: `${pkgs.gnome.gnome-keyring}/bin/gnome-keyring-daemon` doesn't work and results in
        #`no process capabilities, insecure memory might get used` error.
        # `/run/wrappers/bin/gnome-keyring-daemon` works and has `cap_ipc_lock=ep`.
        # https://github.com/NixOS/nixpkgs/blob/683aa7c4e385509ca651d49eeb35e58c7a1baad6/nixos/modules/services/desktops/gnome/gnome-keyring.nix#L44-L49
        # https://github.com/NixOS/nixpkgs/blob/683aa7c4e385509ca651d49eeb35e58c7a1baad6/pkgs/desktops/gnome/core/gnome-keyring/default.nix#L85-L93
        #
        # We're also using the ssh-agent from gcr instead of gnome-keyring.
        ExecStart = "/run/wrappers/bin/gnome-keyring-daemon --start --foreground --components=\"pkcs11,secrets\" --control-directory=\"%t/keyring\"";
        Restart = "on-abort";
    };
  };

  # https://gitlab.gnome.org/GNOME/gcr/-/blob/78e5f89016635b4c4922e63f599b8ec81ea4b923/gcr/gcr-ssh-agent.service.in
  systemd.user.services.gcr-ssh-agent = {
    Unit = {
      Description = "GCR ssh-agent wrapper";
      Requires = [ "gcr-ssh-agent.socket" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      StandardError = "journal";
      Environment = "SSH_AUTH_SOCK=%t/gcr/ssh";
      ExecStart = "${gcr-with-ssh}/libexec/gcr-ssh-agent --base-dir %t/gcr";
      Restart = "on-failure";
    };
  };

  # https://gitlab.gnome.org/GNOME/gcr/-/blob/78e5f89016635b4c4922e63f599b8ec81ea4b923/gcr/gcr-ssh-agent.socket.in
  systemd.user.sockets.gcr-ssh-agent = {
    Unit = {
      Description = "GCR ssh-agent wrapper";
    };
    Install = {
      WantedBy = [ "sockets.target" ];
    };
    Socket = {
      Priority = 6;
      Backlog = 5;
      ListenStream = "%t/gcr/ssh";
      ExecStartPost= "-@systemctl@ --user set-environment SSH_AUTH_SOCK=%t/gcr/ssh";
      DirectoryMode = 0700;
    };
  };
}
