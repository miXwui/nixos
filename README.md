# NixOS Configurations

To be stored in `$XDG_NIXOS_DIR/`.

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

Remove all but the current generation with `sudo nix-collect-garbage --delete-older-than`.

Also should run without `sudo`, as:

> nix-collect-garbage is per user, so you need to execute it per each user that might have store paths that need cleaning up

<https://discourse.nixos.org/t/no-free-disk-space-and-a-lot-of-duplicates-in-nix-store/47515/4>

Remove old entries and rebuild boot options:

```sh
sudo nix-collect-garbage --delete-older-than 30d && nix-collect-garbage --delete-older-than 30d && sudo nixos-rebuild boot --flake $XDG_NIXOS_DIR/.#framework_13_amd_7840u
```

or

```sh
sudo nix-collect-garbage --delete-older-than 30d && nix-collect-garbage --delete-older-than 30d && sudo /run/current-system/bin/switch-to-configuration boot
```

Running with `sudo` deletes system profiles, and without deletes only current user's.

Pass `--delete-old`/`-d` instead of `--delete-older-than` to delete all old generations.

<https://nix.dev/manual/nix/2.18/command-ref/nix-env/delete-generations#generations-time>

```sh
nix-env --delete-generations +5 --dry-run
```

Also `(sudo) nix store gc` and `nix store optimise`.

### Remove a directory in Nix store

`nix store delete /nix/store/path`

### Build ISO

[`flake.nix`](./flake.nix) is set up to use [nixos-generators](https://github.com/nix-community/nixos-generators):

```sh
nix build $XDG_NIXOS_DIR/.#iso
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
nix build $XDG_NIXOS_DIR/.#nixosConfigurations.live-image.config.system.build.isoImage
```

## XDG user directories

Set in `xdg.userDirs` in [home.nix](hosts/home.nix). See for full list.

The values can be accessed within `nix` flakes like so:\
`"${config.xdg.userDirs.extraConfig.XDG_WALLPAPERS_DIR}"`.

The environment variables can be used in scripts, e.g. `$XDG_WALLPAPERS_DIR`.

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

## Power management/battery life

### [fw-ectool](https://gitlab.howett.net/DHowett/ectool)

#### Show charge limit

```sh
sudo ectool fwchargelimit
```

#### Set charge limit

```sh
sudo ectool fwchargelimit 80
```

### s2idle checks

#### Debugging higher idle power consumption after resume from s2idle

<https://community.frame.work/t/responded-higher-idle-power-consumption-after-resume-from-s2idle/50537>

[Compare `/sys/kernel/debug/amd_pmf/current_power_limits` before and after](https://community.frame.work/t/responded-higher-idle-power-consumption-after-resume-from-s2idle/50537/m).

[Check brightness value from sysfs](https://community.frame.work/t/responded-higher-idle-power-consumption-after-resume-from-s2idle/50537/12):

```sh
cat /sys/class/backlight/amdgpu_bl1/brightness
cat /sys/class/backlight/amdgpu_bl1/actual_brightness
```

> [Can you compare `lspci -vv` output before and after suspend? Does L1SS change for any device? If so; it’s pointing at a kernel driver or firmware bug for that device.](https://community.frame.work/t/responded-higher-idle-power-consumption-after-resume-from-s2idle/50537/13)

Useful to compare with (thanks to OP!): <https://gist.github.com/ZachLiu519/5d932675be4997f811c73870a745d6a4>

#### AMD

The <https://gitlab.freedesktop.org/drm/amd> repo is cloned to `$XDG_PROJECTS_DIR/git-clones/drm/amd`.

Run `amd/scripts/amd_s2idle.py`.

These Python packages are required:

```text
distro
gi
packaging
pyudev
systemd
```

These packages are required:

```text
acpica-tools
```

`"msr"` needs to be added to kernel modules:

```nix
boot.kernelModules = [ "msr" ];
```

### Check if anything is inhibiting idle

There is a `yidle` alias/command that runs `.config/sway/scripts/get-idle-inhibitors`.

Its foundation:

```sh
swaymsg -t get_tree -r | jq -C '..|select(objects) | select(.inhibit_idle == true) | {pid, app_id, inhibit_idle, name}'
```

### Adaptive Backlight Management (ABM)

Specifically for AMD.

<https://community.frame.work/t/adaptive-backlight-management-abm/41055/>
<https://docs.kernel.org/gpu/amdgpu/module-parameters.html?highlight=abmlevel>

`0` is off, `1` is least reduction, `4` is max.

```sh
echo [0-4] | sudo tee /sys/class/drm/card1-eDP-1/amdgpu/panel_power_savings
```

Currently automatically set by `TLP` or `power-profiles-daemon`.

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
`$XDG_NIXOS_DIR/secrets/.config/sops/age/keys.txt`.

So be sure these required files are added (the `secrets/` dir is gitignored):

* `$XDG_NIXOS_DIR/secrets/.config/sops/age/keys.txt`
* `$XDG_NIXOS_DIR/secrets/secrets.yaml`

### SSH keys

Systemd `ssh-config.service` defined in `hosts/base.nix` will automatically set up and write files to `~/.ssh` using `sops-nix`.

See `modules/home-manager/ssh.nix`.

### Adding new secrets

`sops $XDG_NIXOS_DIR/secrets/secrets.yaml` which will decrypt and open the file for editing.

### Passing secrets to other processes

 <https://github.com/getsops/sops?tab=readme-ov-file#passing-secrets-to-other-processes>

`sops exec-env secrets.yaml 'echo secret: $some_secret; ./some-script`

## VPN

Packaged [PIA manual-connections](https://github.com/pia-foss/manual-connections) in `packages/pia_manual-connections`.

Installed via `modules/nixos/vpn.nix`.

It uses `sops` to decrypt the username/password and pass as variables into the startup script.

`pia-connect`/`pia-disconnect` to, well, connect and disconnect.

There are a few useful args that can be changed for `pia-connect`.

IPv6 will be disabled (since apparently it's not supported by PIA). The disconnect script will re-enable it.

## Notable programs

* [Sway](https://github.com/swaywm/sway) (with [SwayFX](https://github.com/WillPower3309/swayfx) toggle)
* Power management
  * Switch between:
    * [TLP](https://github.com/linrunner/TLP)
    * [power-profiles-daemon](https://gitlab.freedesktop.org/upower/power-profiles-daemon)
  * [UPower](https://gitlab.freedesktop.org/upower/upower)
  * [poweralertd](https://sr.ht/~kennylevinsen/poweralertd/)
* [KDE Connect](https://github.com/KDE/kdeconnect-kde)
* [Geoclue](https://gitlab.freedesktop.org/geoclue/)
  * Uses Google geolocation API.
  * Systemd `geoclue-config.service` write url with API key (from `sops-nix`) to `/etc/geoclue/conf.d/90-custom-wifi.conf`.
* ~~[Gammastep](https://gitlab.com/chinstrap/gammastep) for automatic color temperature adjustment based on location.~~ disabled for now since I think it's causing higher power consumption.
  * Currently set up to use Geoclue.
* [amd_s2idle](packages/drm_amd) check/verify s2idle and power draw. `sudo amd_s2idle`.

## Nix cookbook

<https://nixos.wiki/wiki/Nix_Cookbook>

* [Wrapping packages](https://nixos.wiki/wiki/Nix_Cookbook#Wrapping_packages)

## Getting SRI hash

```fish
$ bass nix hash to-sri --type sha256 $(nix-prefetch-url "https://git.kernel.org/pub/scm/linux/kernel/git/superm1/linux.git/patch/?id=23fddba4039916caa6a96052732044ddcf514886")
path is '/nix/store/ssa6aqvdfpsgdpd2yb6rs2n0vmr3hk1d-?id=23fddba4039916caa6a96052732044ddcf514886'
sha256-q57T2Ko79DmJEfgKC3d+x/dY2D34wQCSieVrfWKsF5E=
```

<https://www.reddit.com/r/Nix/comments/171ijju/comment/k3rbx44/>

## nix-shell

E.g. for <https://gitlab.freedesktop.org/drm/amd/>:

```sh
 nix-shell --pure -p gobject-introspection fw
upd json-glib 'python3.withPackages(ps: with ps; [ pyg
object3 ])'
```

## Clone a Git repo to home directory

This example clones a repo, then runs a command on the repo.

Note that `builtins.fetchGit` saves to a read-only Nix store for users, and the directory is symlinked to it.

```nix
# For `amd_s2idle.py` script, etc.
"projects/git-clones/drm/amd" = {
  source = pkgs.runCommand "modified-amd-repo" {
    src = builtins.fetchGit {
      url = "https://gitlab.freedesktop.org/drm/amd.git";
      rev = "449cf64fdd71ac14893e8e9fd2eeb65ac65cdd84";
    };
  } ''
    cp -r $src $out
    chmod -R u+w $out
    find $out -type f -exec sed -i \
    -e 's|#!/usr/bin/python3|#!/usr/bin/env python|g' \
    -e 's|#!/usr/bin/python|#!/usr/bin/env python|g' \
    {} +
  '';      
};
```

Though this is packaged up in a flake [here](packages/drm_amd.nix) and [here](modules/nixos/drm_amd.nix).

## Kernel

### Adding kernel patches

This adds a named `specialisation` with kernel patches that will appear as a separate boot entry.

```nix
  specialisation.drm-amdgpu-vcn = { inheritParentConfig = true; configuration =
    {
      boot.kernelPatches = [
        # https://gitlab.freedesktop.org/drm/amd/-/issues/3195#note_2485525
        {
          name = "1-identify-unified-queue";
          patch = (builtins.fetchurl {
            url = "https://git.kernel.org/pub/scm/linux/kernel/git/superm1/linux.git/patch/?id=23fddba4039916caa6a96052732044ddcf514886";
            sha256 = "sha256-q57T2Ko79DmJEfgKC3d+x/dY2D34wQCSieVrfWKsF5E=";
          });
        }
        {
          name = "2-not-pause-dpg";
          patch = (builtins.fetchurl {
            url = "https://git.kernel.org/pub/scm/linux/kernel/git/superm1/linux.git/patch/?id=3941fd6be7cf050225db4b699757969f8950e2ce";
            sha256 = "sha256-JYOLF5ZUxDx9T9jaZCvSQtowUq38qiGPsmAMlaCi5qg=";
          });
        }
      ];
    };
  };
```

One can also switch to a specialized configuration with `sudo /run/current-system/specialisation/fewJobsManyCores/bin/switch-to-configuration test`.\
<https://search.nixos.org/options?&show=specialisation>

Or extract `boot.kernelPatches` to apply it to the config without being under a separate `specialisation`.

### List available kernels

<https://nixos.wiki/wiki/Linux_kernel#List_available_kernels>

Tab complete `pkgs.linuxPackages`.

```sh
$ nix repl

nix-repl> :l <nixpkgs>
Added 12607 variables.

nix-repl> pkgs.linuxPackages
```

#### See current patch version

`nix-search linux-manual` seems to show the current version.

This seems to as well: <https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/kernels-org.json>

### Pinning a kernel version

<https://nixos.wiki/wiki/Linux_kernel#Pinning_a_kernel_version>

Warning: This will compile the kernel and take a while.

Example (add to `base.nix` under `### KERNEL ###`):

```nix
boot.kernelPackages = pkgs.linuxPackagesFor (
  pkgs.linux_6_11.override {
    argsOverride = rec {
      src = pkgs.fetchurl {
        url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
        sha256 = "sha256-BXJj0K/BfVJTeUr9PSObpNpKpzSyL6NsFmX0G5VEm3M=";
      };
      version = "6.11.3";
      modDirVersion = "6.11.3";
    };
  }
);
```

### Build Fedora kernel

<https://nixos.org/manual/nixos/stable/#sec-linux-config-customizing>
<https://nixos.org/manual/nixpkgs/stable/#sec-linux-kernel>
<https://nixos.wiki/wiki/Linux_kernel>

Useful for testing/diffing, e.g. in the case that the Fedora kernel has a lower idle power draw than the NixOS default kernel.

```nix
let
  fedoraKernel = (pkgs.linuxKernel.manualConfig rec {
    version = "6.9.11";
    modDirVersion = version;
    configfile = ./kernel-x86_64-fedora.noquotes.config;
    allowImportFromDerivation = true;
    src = pkgs.fetchurl {
      # https://github.com/NixOS/nixpkgs/blob/28b3994c14c4b3e36aa8b6c0145e467250c8fbb8/pkgs/os-specific/linux/kernel/mainline.nix#L19
      url = "https://cdn.kernel.org/pub/linux/kernel/v${lib.versions.major version}.x/linux-${version}.tar.gz";
      sha256 = "0f69315a144b24a72ebd346b1ca571acef10e9609356eb9aa4c70ef3574eff62";
    };
  # https://github.com/NixOS/nixpkgs/issues/216529
  # https://github.com/NixOS/nixpkgs/pull/288154#pullrequestreview-1901852446
  }).overrideAttrs(old: {
    passthru = old.passthru // {
      features = {
        ia32Emulation = true;
        efiBootStub = true;
      };
    };
  });
in
{
  boot.kernelPackages = pkgs.linuxPackagesFor fedoraKernel;
}
```

#### .config

<https://src.fedoraproject.org/rpms/kernel>
<https://src.fedoraproject.org/rpms/kernel/raw/f40/f/kernel-x86_64-fedora.config>

> You can see the configuration of your current kernel with the following command:

  ```sh
  zcat /proc/config.gz
  ```

#### Kernel source

<https://cdn.kernel.org/pub/linux/kernel/v6.x/>
<https://cdn.kernel.org/pub/linux/kernel/v6.x/sha256sums.asc>

#### Misc

```text
root module: pcips2
modprobe: FATAL: Module pcips2 not found in directory /nix/store/9ngpgsnvky7fqbc28hvdi3ccpn5p3h0n-linux-6.9.11-modules/lib/modules/6.9.11
```

Apparently copying some options from config fixed the issue, but I didn't record it, so *shrugs*.

## Helix

Overall, really, really enjoying Helix now as my primary editor. Switched from about 10 years of VSCode, with a short but deep sting in Emacs-land.

It's really amazing on power efficiency and also the quickest (from testing). And I love it's style of modal editing, with tweaks of course.

Nagit is really something special and thankfully there's a standalone Rust implementation, [Gitu](https://github.com/altsem/gitu). Works well for my usecase, so far.

* [To match lines that contain a substring](https://www.reddit.com/r/HelixEditor/comments/11sbk1j/how_can_i_delete_all_lines_containing_a_substring/): (`%`: `select_all`), (`s`: `select_regex`), (`x`: `extend_line_below`).
  * [that do not contain](https://github.com/helix-editor/helix/discussions/7342): (`%`: `select_all`), (`A-s`: `split_selection_on_newline`), (`A-K`: `remove_selections`)
* Macros are useful, (`Q`: `record_macro`) to start/stop record, and (`q`: `replay_macro`) to play.
* [Find next occurence of selection under cursor](https://www.reddit.com/r/HelixEditor/comments/1aqif6u/find_next_occurrence_of_word_under_cursor/): `*` to yank to search register. (`n`: `search_next`) / (`p`: `search_prev`)

## Emacs

NOTE: I came out of the rabbit hole frustrated with the slowness/power efficiency of Emacs relative to Helix. So I switched to Helix.

I was using [Meow](https://github.com/meow-edit/meow) in Emacs so the Kakoune inspired modal editing workflow is similar.

I do miss some things with Emacs, but they should mostly be reproducible in Helix at some point and with the long-awaited plugin system.

~~I've switched to Emacs after about 10 years of VSCode after some careful consideration among other options. Lot of effort, so many tweaks, but it's something that should hopefully last forever and I won't need to migrate. Briefly, out of the box, Emacs is horrible IMO. But everything's configurable, and even though it takes a lot of time and effort to learn and setup, tradeoffs so far seem to be worth it. A lot of things are overly complicated, but things remain possible to do and easily fixable due to its inherent configurability vs. other platforms.~~

~~The reduced energy (battery) usage and entirely keyboard driven workflow, among some other features (and there are a *lot*, a metric-yacht-load!) make usage incredible, despite the initial setup pains. If anyone else is reading this as a beginner, I'd recommend using an out of the box setup like Doom Emacs to see what's possible, and continue grinding through it and figuring out how to get that thing you want. It may take writing a custom function, but there's probably a simple and clean solution that allows you to do even more than you thought possible since Emacs has a ton of widgets.~~

## Zed editor needs this to install dev extensions

```text
rustc
rustup
gcc
```

Run 'rustup default stable' to download the latest stable release of Rust and set it as your default toolchain.

## Zellij

<https://zellij.dev/screencasts/>

### [Basic develoment with Zellij](https://zellij.dev/tutorials/basic-functionality/)

1. `cd` into project dir.
2. `hx .`
3. `C-p` for `pane` mode.
4. `d` to split down.
5. `A-n` opens new pane.
6. `C-p-e` for floating pane (Ctrl-pane-eject).
7. `C-p-w` to toggle it on/off.
8. Prepend `zellij run --floating` (aliased to `zrf`) to a command to run it in it's own window.
   Pressing `enter` on the window can re-run it (although it doesn't keep `sudo` context since it seems to run a new instance each time).
9. `C-s-e` (Ctrl-scrollback-edit) to edit the scrollback in your default editor.

`A-[`/`]` to change pane layout. It's also useful for floating panes.

`A-+`/`-` to increase/decrease pane size.

### [Using layouts for personal automation](https://zellij.dev/tutorials/layouts/)

See this repo's [Zellij `default-layout.kdl`](default-layout.kdl).\
More examples: <https://zellij.dev/documentation/layout-examples>.

Easiest way I've found so far is to manually create the layout, then run:

```sh
zellij action dump-layout
```

New Zellij session:

```sh
zellij -l /path/to/layout.kdl
```

Inside an existing session:

```sh
zellij action new-tab -l /path/to/layout.kdl
```

### [Session management with Zellij](https://zellij.dev/tutorials/session-management/)

`zjw` is aliased for `zellij -l welcome`.

### [The Zellij filepicker](https://zellij.dev/tutorials/filepicker/)

```kdl
keybinds {
  shared_except "locked" {
  // ...
    bind "Alt f" {
      LaunchPlugin "filepicker" {
        // floating true // uncomment this to have the filepicker opened in a floating window
        close_on_selection true // comment this out to have the filepicker remain open even after selecting a file
      };
    }
  }
}
```

`C-e` to toggle hidden files/folders.

`zellij plugin -- filepicker` from command line.

`zellij -l strider` layout for "IDE-like" experience.

`zellij action new-tab -l strider` in an existing session.

`zpipe` alias for `zellij pipe -p`.

`zpipe filepicker` or `zpf` for `zellij pipe -p filepicker` to pipe its output to `STDOUT`.

E.g. to open the filepicker to select a file to copy to `path/some-file`:

```sh
zpf | xargs -i cp {} path/some-file
```

#### Run multiple commands with `sudo`

```kdl
pane command="sudo" {
  start_suspended true
  cwd "$XDG_NIXOS_DIR"
  args "sh" "-c" "nix-collect-garbage --delete-older-than 30d && nixos-rebuild boot --flake .#framework_13_amd_7840u"
}
```

Also see: <https://github.com/zellij-org/zellij/discussions/3459>

#### `compact-bar` pane

To add, run this in a floating window in a layout that has the `compact-bar`:

```sh
zellij setup --dump-layout compact
```

Which has this relevant part:

```kdl
pane size=1 borderless=true {
  plugin location="compact-bar"
}
```

Paste that into your layout.

#### Command pane repetition

Example:

```kdl
pane split_direction="horizontal" {
  cargo { args "run"; }
  cargo { args "test"; }
  cargo { args "check"; }
}
pane_template_name name="cargo" {
  command "cargo"
  start_suspended true
}
```

## Rust

### Build older version from crate

```nix
zellij_0-38 = pkgs.zellij.overrideAttrs (old: rec {
  version = "0.38.2";
  src = pkgs.fetchFromGitHub {
   owner = "zellij-org";
   repo = "zellij";
   rev = "eb18af029e6ddc692baacf49666354694e416d53";
   hash = "sha256-rq7M4g+s44j9jh5GzOjOCBr7VK3m/EQej/Qcnp67NhY=";
  };
  cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${old.pname}-${version}";
    hash = "sha256-xK7lLgjVFUISo4stF6MgfgI4mT5qHuph70cyYaLYZ30=";
  };
});
```

## Music

Using [mpd](https://www.musicpd.org/) with [ncmpcpp](https://github.com/ncmpcpp/ncmpcpp)

[mpc](https://www.musicpd.org/clients/mpc/) is also installed.

Has a lot of useful commands like `mpc stats`, `update`.

### ncmpcpp cheatsheet

<https://pkgbuild.com/~jelle/ncmpcpp/>

### Issues

#### Not applying GID change during boot

I was getting this warning during boot in `NixOS Stage 2` after `running activation script`:

```text
warning: not applying GID change of group uinput (990 -> 327) in /etc/group/
```

See this: <https://github.com/NixOS/nixpkgs/issues/19599#issuecomment-254226192>

To manually fix:
Read this [answer](https://unix.stackexchange.com/a/33874) and this [comment](https://unix.stackexchange.com/questions/33844/change-gid-of-a-specific-group#comment215709_33874).

1. `groupmod -g NEWGID GROUPNAME`
    1. `sudo groupmod -g 327 uinput`
2. `sudo find / -gid OLDGID ! -type l -exec chgrp NEWGID {} \;\`
    1. > Suggest using chgrp -h ... instead of chgrp .... Without -h, the target of any relevant symlink will have its group changed.
    2. `sudo find / -gid 990 ! -type l -exec chgrp 327 {} \;`
    3. Or, manually find and change.

`ls -n` to see the numeric UID/GID of file.

#### Diagnosing long boot times

* `systemd-analyze critical-chain`
* `systemd-analyze blame`
* `systemd-analyze plot > boot-analysis.svg`
* `journalctl -b -k`
* `systemctl status --lines 1000 home-manager-mwu.service`

I also have flags in `base.nix` in `boot_debug` for:

* `.enable`:                  Enabling verbose boot logs
* `.network_no_wait_online`:  Not waiting for network to be online during boot
* `.network_no_wait_startup`: Not waiting for network startup during boot
* `.home_manager_verbose`:    Enabling verbose Home Manager logs

#### Remove/delete files/folders

If a file/folder gets stuck and you can't remove it even as root, you can create a script in `home.activation` like so:

```nix
home.activation = {
  # Scripts to run during the activation phase.
  removeFolder = ''
    rm -rf /home/mwu/projects/scripts
  '';
};
```
