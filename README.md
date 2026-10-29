# manēso

<p align="center">
  <img src="logo.png" alt="manēso logo" width="480">
</p>

**manēso — A Dynamic Island for MangoWM**

**Your desktop, in motion.**

A modern, animated Dynamic Island for MangoWM on Wayland. Built with Quickshell and QML.

## Features

- Animated island with hover or click expansion
- Workspace tags, focused window, and keyboard layout indicators
- Media controls via MPRIS and MPD
- Volume, brightness, and keyboard-layout on-screen displays
- Notification center with history and grouping
- System tray, privacy indicators, and system statistics
- Bluetooth, network, and power status
- Built-in settings panel
- Matugen color integration
- IPC commands for scripting and keybindings

## Requirements

- MangoWM on Wayland
- [Quickshell](https://quickshell.org/) with Qt 6 QML
- `wpctl` for PipeWire volume control
- `brightnessctl` for internal display brightness
- `ddcutil` for external display brightness
- `ffmpeg` for extracting MPD artwork

These tools are only needed for the features that use them. The diagnostics page
reports any missing tools, including `notify-send` if it is not installed.

## Installing Quickshell

Quickshell is packaged by most distributions. Use the command for your
distribution, or build it manually from the
[Quickshell repository](https://github.com/quickshell-mirror/quickshell).

| Distribution            | Install command                                                                                                                                                                                                |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Arch Linux              | `sudo pacman -S quickshell`                                                                                                                                                                                    |
| Arch Linux (AUR, git)   | `yay -S quickshell-git`                                                                                                                                                                                        |
| Fedora (COPR)           | `sudo dnf copr enable errornointernet/quickshell`<br>`sudo dnf install quickshell`                                                                                                                             |
| Fedora Rawhide          | `sudo dnf install quickshell`                                                                                                                                                                                  |
| Debian testing/unstable | `sudo apt install quickshell`                                                                                                                                                                                  |
| Ubuntu (DankLinux PPA)  | `sudo add-apt-repository ppa:avengemedia/danklinux`<br>`sudo apt update`<br>`sudo apt install quickshell`                                                                                                      |
| openSUSE Tumbleweed     | `sudo zypper addrepo https://download.opensuse.org/repositories/home:/AvengeMedia:/danklinux/openSUSE_Tumbleweed/home:AvengeMedia:danklinux.repo`<br>`sudo zypper refresh`<br>`sudo zypper install quickshell` |
| openSUSE Slowroll       | `sudo zypper addrepo https://download.opensuse.org/repositories/home:/AvengeMedia:/danklinux/openSUSE_Slowroll/home:AvengeMedia:danklinux.repo`<br>`sudo zypper refresh`<br>`sudo zypper install quickshell`   |
| NixOS / Nix             | `nix profile install nixpkgs#quickshell`                                                                                                                                                                       |
| Gentoo (GURU)           | `sudo eselect repository enable guru`<br>`sudo emerge --sync guru`<br>`sudo emerge gui-apps/quickshell`                                                                                                        |
| Guix                    | `guix install quickshell`                                                                                                                                                                                      |

On NixOS, prefer adding `pkgs.quickshell` to `environment.systemPackages` or
`home.packages`. On Gentoo, install `eselect-repository` before enabling GURU.
The AUR command assumes `yay`; substitute your preferred AUR helper.

Depending on the distribution, install `qtsvg`, `qtimageformats`,
`qtmultimedia`, and `qt5compat` for SVG icons, additional image formats, media,
and blur effects.

## Running

Run the configuration directly from its checkout:

```sh
qs -p /path/to/maneso
```

Alternatively, place or symlink the checkout at
`$XDG_CONFIG_HOME/quickshell/maneso` and launch it by name:

```sh
qs -c maneso
```

## Configuration

See [CONFIGURATION.md](CONFIGURATION.md) for all available settings, their defaults, and accepted values.

## IPC

The island keeps its existing `island` IPC target so that current scripts and
keybindings continue to work:

```sh
qs -c maneso ipc call island toggle
qs -c maneso ipc call island status
qs -c maneso ipc call island toggleNotifications
qs -c maneso ipc call island toggleSettings
```

If you launch the configuration with `qs -p`, pass the same path to the IPC
command instead, for example
`qs -p /path/to/maneso ipc call island toggle`.

## Naming

- User-facing name: **manēso**
- ASCII identifier: **maneso**
