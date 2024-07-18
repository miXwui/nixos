# NixOS Configurations

To be stored in `/home/<user>/nixos/`.

## Useful references (thanks!)

[Modularize NixOS and Home Manager | Great Practices](https://www.youtube.com/watch?v=vYc6IzKvAJQ)

## Building

### Rebuild

`sudo nixos-rebuild switch --flake .#framework_13_amd_7840u`

### Hosts/devices

* framework_13_amd_7840u
* framework_13_intel_i7-1165g7
* dell_xps_15_9550_intel_i7-6700hq_and_nvidia_gtx-960m
* qemu

### Remove old boot entries

<https://nixos.wiki/wiki/Storage_optimization>

Remove all but the current generation with `sudo nix-collect-garbage -d`.

Remove old entries and rebuild boot options:

```sh
sudo nix-collect-garbage -d && sudo nixos-rebuild boot --flake .#framework_13_amd_7840u
```

or

```sh
sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot
```

### Build ISO

[`flake.nix`](./flake.nix) is set up to use [nixos-generators](https://github.com/nix-community/nixos-generators):

```sh
nix build .#iso
```

[This](https://www.reddit.com/r/NixOS/comments/18gkafh/comment/kd13m58/) also works if added to `flake.nix`:

```nix
{
  nixosConfigurations = {
    live-image = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
        ./hosts/live-image/configuration.nix
        inputs.home-manager.nixosModules.default
        { nixpkgs.overlays = overlays; }
      ];
    };
};
}
```

```sh
nix build .#nixosConfigurations.live-image.config.system.build.isoImage
```

## Packages

### Install a specific version of a package

Find details from <https://lazamar.co.uk/nix-versions/> or search the Git repo for the PR/commit.

Then modify `hosts/home.nix` like so:

```nix
let
  old = import (builtins.fetchGit {
    name = "waybar-old";
    url = "https://github.com/NixOS/nixpkgs/";
    ref = "refs/heads/nixpkgs-unstable";
    rev = "db92283eff575ac2a78d7b2d65d2dad4f7acf14a";
  }) { system = "x86_64-linux"; };
in
{
  home.packages = with pkgs; [
    old.waybar
  ]
}
```

### Search packages

```sh
nix-search <package name>
```

## Keyboard

The internal keyboard is disabled by default, and [`keyd`](https://github.com/rvaiya/keyd) intercepts the internal keyboard presses [remapped to a more ergonomic "split" layout with thumb modifiers](https://community.frame.work/t/guide-a-more-ergonomic-keyboard-layout-symmetric-staggered-qwerty-us-ansi-framework-13/45150).

Since I use an external split keyboard for ergonomics, I can place it on top of the laptop and `systemctl stop keyd` to stop the service, completely disabling the internal keyboard altogether. `systemctl start keyd` to re-enable.

A `nixos rebuild switch` or reboot will re-enable it, since the `keyd` service starts at boot.

### Disable internal laptop keyboard when another keyboard is connected

This is taken care of in [hardware_input-laptop.nix](common/hardware_input-laptop.nix).

Here is a breakdown of the manual steps:

1. Install `libinput` (`services.libinput.enable = true`).
2. Find the input device paths from `libinput list-devices`.

or

1 Install `evtest`
2. `sudo evtest`
3. Find input event number
4. Get `ATTRS{id/vendor}` and `ATTRS{id/product}` from `udevadm info --attribute-walk --path=$(udevadm info --query=path --name=/dev/input/event<N>) | grep 'vendor\|product'`

Then,

1. Add to udev rule file, e.g.: `/etc/udev/rules.d/99-disable-internal-keyboard.rules` or on Nix in `services.udev.extraRules`:

    ```text
    # Disable internal keyboard when Bluetooth keyboard (Lily58) is connected
    ACTION=="add", SUBSYSTEM=="input", ENV{ID_INPUT_KEYBOARD}=="1", KERNELS=="<bluetooth_keyboard_path>", RUN+="/usr/bin/libinput disable-device /dev/input/event14"
    # Enable internal keyboard when Bluetooth keyboard (Lily58) is disconnected
    ACTION=="remove", SUBSYSTEM=="input", ENV{ID_INPUT_KEYBOARD}=="1", KERNELS=="<bluetooth_keyboard_path>", RUN+="/usr/bin/libinput enable-device /dev/input/event0"
    ```

2. Reload udev rules: `sudo udevadm control --reload-rules`.

For more info: <https://unix.stackexchange.com/questions/381944/how-to-disable-internal-keyboard-on-fedora-26-wayland/702857#702857>

## Fingerprint

User files are stored under `/var/lib/fprint/<user>` which can be migrated to another installation ([ref](https://community.frame.work/t/cross-distro-dualboot-and-or-reinstall-save-your-var-lib-fprint-user-files-from-the-one-that-works/12908/2)).\
The actual fingerprints for Framework 13 apparently are stored directly on the sensor.

## Firmware

```sh
fwupdmgr refresh
fwupdmgr get-updates
fwupdmgr update
```

## Keyring

* [`hosts/base.nix`](./hosts/base.nix)
* [`modules/home-manager/keyring.nix`](./modules/home-manager/keyring.nix)

We use Gnome Keyring for `pkcs11` and `secrets`. We use `gcr` for SSH since [that functionality has been moved there](https://gitlab.gnome.org/GNOME/gnome-keyring/-/merge_requests/60).

Seahorse (Passwords and Keys) is also installed.

## Secrets

Managed using [`sops-nix`](https://github.com/Mic92/sops-nix/).

* Video guide: [NixOS Secrets Management | SOPS-NIX](https://www.youtube.com/watch?v=G5f6GC7SnhU)

### Generating using [`ssh-to-age`](https://github.com/Mic92/ssh-to-age?tab=readme-ov-file#usage)

1. Generate new ssh age key:

   ```sh
   nix shell nixpkgs#age -c age-keygen -o secrets/.config/sops/age/keys.txt
   ```

2. Or generate age key from existing ssh key:

   ```sh
   nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/id_ed25519 > secrets/.config/sops/age/keys.txt
   ```

   If the ssh key has a passphrase, run this before:

   ```sh
   read -s SSH_TO_AGE_PASSPHRASE; export SSH_TO_AGE_PASSPHRASE
   ```

3. Get the public key:

   ```sh
   nix shell nixpkgs#age -c age-keygen -y secrets/.config/sops/age/keys.txt
   ```

#### Creating SOPS secrets file

```sh
mkdir secrets
cd secrets
sops secrets.yaml
```

### Files needed

Instead of using the default SOPS path `~/.config/sops/age/keys.txt`, we set the `SOPS_AGE_KEY_FILE` environment variable in `hosts/base.nix` to:
`/home/<user>/nixos/secrets/.config/sops/age/keys.txt`.

So be sure these required files are added (the `secrets/` dir is gitignored):

* `/home/<user>/nixos/secrets/.config/sops/age/keys.txt`
* `/home/<user>/nixos/secrets/secrets.yaml`

### SSH keys

Systemd `ssh-config.service` defined in `hosts/base.nix` will automatically set up and write files to `~/.ssh` using `sops-nix`.

See `modules/home-manager/ssh.nix`.

## Notable programs

* [Sway](https://github.com/swaywm/sway) (with [SwayFX](https://github.com/WillPower3309/swayfx) toggle)
* [TLP](https://github.com/linrunner/TLP)
* [KDE Connect](https://github.com/KDE/kdeconnect-kde)
* [Geoclue](https://gitlab.freedesktop.org/geoclue/)
  * Uses Google geolocation API.
  * Systemd `geoclue-config.service` write url with API key (from `sops-nix`) to `/etc/geoclue/conf.d/90-custom-wifi.conf`.
* [Gammastep](https://gitlab.com/chinstrap/gammastep) for automatic color temperature adjustment based on location.
  * Currently set up to use Geoclue.
