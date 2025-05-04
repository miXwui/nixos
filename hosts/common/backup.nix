{
  config,
  gProgs,
  xdg_nixos_dir,
  ...
}:
{

  ### SOPS ###
  sops = {
    templates = {
      "hetzner-storage-box_rclone-env-vars" = {
        content = ''
          RCLONE_WEBDAV_URL=https://${config.sops.placeholder.hetzner_storage_box_sub_account}.${config.sops.placeholder.hetzner_storage_box_server}
          RCLONE_WEBDAV_USER=${config.sops.placeholder.hetzner_storage_box_sub_account}
          RCLONE_WEBDAV_PASS=${config.sops.placeholder.hetzner_storage_box_sub_account_password_rclone_obscured}
          RCLONE_WEBDAV_VENDOR=other
        '';
      };
    };
  };

  ### SYSTEMD SERVICE ###
  services.restic.backups = {
    hetzner-storage-box = {
      initialize = true;

      backupPrepareCommand = ''
        systemctl start notify-backup-to-hetzner-storage-box-start.service
      '';
      backupCleanupCommand = ''
        systemctl start notify-backup-to-hetzner-storage-box-complete.service
      '';

      environmentFile = config.sops.templates."hetzner-storage-box_rclone-env-vars".path;
      repositoryFile = config.sops.secrets.hetzner_storage_box_restic_repo.path;
      passwordFile = config.sops.secrets.hetzner_storage_box_restic_repo_framework13_password.path;
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
  };

  ### NOTIFICATIONS ###
  # Started
  systemd.services."notify-backup-to-hetzner-storage-box-start" = {
    enable = true;
    description = "Notify on backup to Hetzner Storage Box starting";
    serviceConfig = {
      Type = "oneshot";
      User = config.main-user.username;
    };

    script = ''
      # required for notify-send
      export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u ${config.main-user.username})/bus"
      ${gProgs.libnotify}/bin/notify-send -h string:desktop-entry:restic_backup --urgency=normal\
          "Backup to Hetzner Storage Box started at $(date +"%m/%d/%y %-I:%M %p %Z")." \
          "$(journalctl -u restic-backups-hetzner-storage-box -n 5 -o cat)"
    '';
  };

  # Completed
  systemd.services."notify-backup-to-hetzner-storage-box-complete" = {
    enable = true;
    description = "Notify on backup to Hetzner Storage Box completed";
    serviceConfig = {
      Type = "oneshot";
      User = config.main-user.username;
    };

    script = ''
      # required for notify-send
      export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u ${config.main-user.username})/bus"
      ${gProgs.libnotify}/bin/notify-send -h string:desktop-entry:restic_backup --urgency=normal \
          "Backup to Hetzner Storage Box completed at $(date +"%m/%d/%y %-I:%M %p %Z")." \
          "$(journalctl -u restic-backups-hetzner-storage-box -n 5 -o cat)"
    '';
  };

  # Failed
  systemd.services.restic-backups-hetzner-storage-box.unitConfig.OnFailure =
    "notify-backup-to-hetzner-storage-box-failed.service";

  systemd.services."notify-backup-to-hetzner-storage-box-failed" = {
    enable = true;
    description = "Notify on failed backup to Hetzner Storage Box";
    serviceConfig = {
      Type = "oneshot";
      User = config.main-user.username;
    };

    script = ''
      # required for notify-send
      export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u ${config.main-user.username})/bus"
      ${gProgs.libnotify}/bin/notify-send -h string:desktop-entry:restic-backup --urgency=critical \
          "Backup to Hetzner Storage Box failed at $(date +"%m/%d/%y %-I:%M %p %Z")!" \
          "$(journalctl -u restic-backups-hetzner-storage-box -n 5 -o cat)"
    '';
  };
}
