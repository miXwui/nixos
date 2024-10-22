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

Remove old entries and rebuild boot options:

```sh
sudo nix-collect-garbage -delete-older-than 30d && sudo nixos-rebuild boot --flake $XDG_NIXOS_DIR/.#framework_13_amd_7840u
```

or

```sh
sudo nix-collect-garbage -delete-older-than 30d && sudo /run/current-system/bin/switch-to-configuration boot
```

Running with `sudo` deletes system profiles, and without deletes only current user's.

Pass `--delete-old`/`-d` instead of `--delete-older-than` to delete all old generations.

<https://nix.dev/manual/nix/2.18/command-ref/nix-env/delete-generations#generations-time>

```sh
nix-env --delete-generations +5 --dry-run
```

Also `(sudo) nix store gc` and `nix store optimise`.

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

## Notable programs

* [Sway](https://github.com/swaywm/sway) (with [SwayFX](https://github.com/WillPower3309/swayfx) toggle)
* [TLP](https://github.com/linrunner/TLP)
* [KDE Connect](https://github.com/KDE/kdeconnect-kde)
* [Geoclue](https://gitlab.freedesktop.org/geoclue/)
  * Uses Google geolocation API.
  * Systemd `geoclue-config.service` write url with API key (from `sops-nix`) to `/etc/geoclue/conf.d/90-custom-wifi.conf`.
* ~~[Gammastep](https://gitlab.com/chinstrap/gammastep) for automatic color temperature adjustment based on location.~~ disabled for now since I think it's causing higher power consumption.
  * Currently set up to use Geoclue.

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
zellij_0-38 = pkgs.unstable.zellij.overrideAttrs (old: rec {
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
