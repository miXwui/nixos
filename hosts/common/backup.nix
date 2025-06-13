{
  config,
  pkgs,
  gProgs,
  xdg_nixos_dir,
  ...
}:
{

  ### SOPS ###
  sops = {
    templates = {
      "hetzner-storage-box_framework-13_rclone-env-vars" = {
        content = ''
          RCLONE_WEBDAV_URL=https://${config.sops.placeholder.hetzner-storage-box_framework-13_sub-account}.${config.sops.placeholder.hetzner-storage-box_server}
          RCLONE_WEBDAV_USER=${config.sops.placeholder.hetzner-storage-box_framework-13_sub-account}
          RCLONE_WEBDAV_PASS=${config.sops.placeholder.hetzner-storage-box_framework-13_sub-account-password-rclone-obscured}
          RCLONE_WEBDAV_VENDOR=other
        '';
      };

      "hetzner-storage-box_sandisk-portable-ssd-2tb_rclone-env-vars" = {
        content = ''
          RCLONE_WEBDAV_URL=https://${config.sops.placeholder.hetzner-storage-box_sandisk-portable-ssd-2tb_sub-account}.${config.sops.placeholder.hetzner-storage-box_server}
          RCLONE_WEBDAV_USER=${config.sops.placeholder.hetzner-storage-box_sandisk-portable-ssd-2tb_sub-account}
          RCLONE_WEBDAV_PASS=${config.sops.placeholder.hetzner-storage-box_sandisk-portable-ssd-2tb_sub-account-password-rclone-obscured}
          RCLONE_WEBDAV_VENDOR=other
        '';
      };
    };
  };

  ### SYSTEMD SERVICE ###
  services.restic.backups = {
    # Hetzner Storage Box - Framework 13
    hetzner-storage-box_framework-13 = {
      initialize = true;

      backupPrepareCommand = ''
        systemctl start notify-restic-backup-start@hetzner-storage-box_framework-13
      '';
      backupCleanupCommand = ''
        systemctl start notify-restic-backup-complete@hetzner-storage-box_framework-13
      '';

      environmentFile = config.sops.templates."hetzner-storage-box_framework-13_rclone-env-vars".path;
      repositoryFile = config.sops.secrets.hetzner-storage-box_framework-13_restic-repo.path;
      passwordFile = config.sops.secrets.hetzner-storage-box_framework-13_restic-repo-password.path;
      rcloneConfigFile = "${xdg_nixos_dir}/home/.config/rclone/rclone.conf";
      extraOptions = [
        "rclone.args='serve restic --stdio --verbose'"
      ];

      paths = [
        "/home/${config.main-user.username}"
        "/var/lib"
      ];

      timerConfig = {
        # everyday at 10PM
        OnCalendar = "22:00";
        # if the system was off/asleep, run after it's back up
        Persistent = true;
        # wait a random amount of time, up to 5min to prevent overload
        RandomizedDelaySec = "5m";
        AccuracySec = "1us";
      };

      pruneOpts = [
        # keep the most recent 7 daily snapshots
        "--keep-daily 7"
        # keep the most recent 5 weekly snapshots
        "--keep-weekly 5"
        # keep the most recent 12 monthly snapshots
        "--keep-monthly 12"
      ];
    };

    # Hetzner Storage Box - Sandisk Portable SSD 2TB
    hetzner-storage-box_sandisk-portable-ssd-2tb = {
      initialize = true;

      backupPrepareCommand = ''
        systemctl start notify-restic-backup-start@hetzner-storage-box_sandisk-portable-ssd-2tb
      '';
      backupCleanupCommand = ''
        systemctl start notify-restic-backup-complete@hetzner-storage-box_sandisk-portable-ssd-2tb
      '';

      environmentFile =
        config.sops.templates."hetzner-storage-box_sandisk-portable-ssd-2tb_rclone-env-vars".path;
      repositoryFile = config.sops.secrets.hetzner-storage-box_sandisk-portable-ssd-2tb_restic-repo.path;
      passwordFile =
        config.sops.secrets.hetzner-storage-box_sandisk-portable-ssd-2tb_restic-repo-password.path;
      rcloneConfigFile = "${xdg_nixos_dir}/home/.config/rclone/rclone.conf";
      extraOptions = [
        "rclone.args='serve restic --stdio --verbose'"
      ];

      paths = [
        "/run/media/${config.main-user.username}/SanDisk PortableSSD 2TB/restic-backup"
      ];

      timerConfig = {
        # everyday at 10PM
        OnCalendar = "22:00";
        # if the system was off/asleep, run after it's back up
        Persistent = true;
        # wait a random amount of time, up to 5min to prevent overload
        RandomizedDelaySec = "5m";
        AccuracySec = "1us";
      };

      pruneOpts = [
        # keep the most recent 7 daily snapshots
        "--keep-daily 7"
        # keep the most recent 5 weekly snapshots
        "--keep-weekly 5"
        # keep the most recent 12 monthly snapshots
        "--keep-monthly 12"
      ];
    };
  };

  # On failure notifiications
  systemd.services.restic-backups-hetzner-storage-box_framework-13.unitConfig.OnFailure =
    "notify-restic-backup-failed@hetzner-storage-box_framework-13.service";

  systemd.services.restic-backups-hetzner-storage-box_sandisk-portable-ssd-2tb.unitConfig.OnFailure =
    "notify-restic-backup-failed@hetzner-storage-box_sandisk-portable-ssd-2tb.service";

  ### NOTIFICATIONS ###
  # Started
  systemd.services."notify-restic-backup-start@" = {
    enable = true;
    description = "Notify a restic backup is starting for %i";
    serviceConfig = {
      Type = "oneshot";
      User = config.main-user.username;
      ExecStart = "${pkgs.writeScript "notify-restic-backup-start" ''
        #!/run/current-system/sw/bin/bash

        TARGET="$1"

        # required for notify-send
        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u ${config.main-user.username})/bus"

        ${gProgs.libnotify}/bin/notify-send \
          -h string:desktop-entry:restic_backup \
          --urgency=normal \
          -- \
          "Backup to $TARGET started at $(date +"%m/%d/%y %-I:%M %p %Z")." \
          "$(journalctl -u restic-backups-$TARGET -n 1 -o cat || echo 'No logs found.')"
      ''} %i";
    };
  };

  # Completed
  systemd.services."notify-restic-backup-complete@" = {
    enable = true;
    description = "Notify a restic backup completed for %i";
    serviceConfig = {
      Type = "oneshot";
      User = config.main-user.username;
      ExecStart = "${pkgs.writeScript "notify-restic-backup-completed" ''
        #!/run/current-system/sw/bin/bash

        TARGET="$1"

        # required for notify-send
        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u ${config.main-user.username})/bus"

        ${gProgs.libnotify}/bin/notify-send \
          -h string:desktop-entry:restic_backup \
          --urgency=normal \
          -- \
          "Backup to $TARGET completed at $(date +"%m/%d/%y %-I:%M %p %Z")." \
          "$(journalctl -u restic-backups-$TARGET -n 5 -o cat || echo 'No logs found.')"
      ''} %i";
    };
  };

  # Failed
  systemd.services."notify-restic-backup-failed@" = {
    enable = true;
    description = "Notify a restic backup failed for %i";
    serviceConfig = {
      Type = "oneshot";
      User = config.main-user.username;
      ExecStart = "${pkgs.writeScript "notify-restic-backup-failed" ''
        #!/run/current-system/sw/bin/bash

        TARGET="$1"

        # required for notify-send
        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u ${config.main-user.username})/bus"

        ${gProgs.libnotify}/bin/notify-send \
          -h string:desktop-entry:restic_backup \
          --urgency=critical \
          -- \
          "Backup to $TARGET failed at $(date +"%m/%d/%y %-I:%M %p %Z")." \
          "$(journalctl -u restic-backups-$TARGET -n 5 -o cat || echo 'No logs found.')"
      ''} %i";
    };
  };
}
