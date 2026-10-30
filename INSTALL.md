# Installing Quickshell

Arch Linux instructions are in the [README](README.md#installing-quickshell).
This file covers the other distributions.

| Distribution | Install command |
|---|---|
| Fedora (COPR) | `sudo dnf copr enable errornointernet/quickshell`<br>`sudo dnf install quickshell` |
| Fedora Rawhide | `sudo dnf install quickshell` |
| Debian testing/unstable | `sudo apt install quickshell` |
| Ubuntu (DankLinux PPA) | `sudo add-apt-repository ppa:avengemedia/danklinux`<br>`sudo apt update`<br>`sudo apt install quickshell` |
| openSUSE Tumbleweed | `sudo zypper addrepo https://download.opensuse.org/repositories/home:/AvengeMedia:/danklinux/openSUSE_Tumbleweed/home:AvengeMedia:danklinux.repo`<br>`sudo zypper refresh`<br>`sudo zypper install quickshell` |
| openSUSE Slowroll | `sudo zypper addrepo https://download.opensuse.org/repositories/home:/AvengeMedia:/danklinux/openSUSE_Slowroll/home:AvengeMedia:danklinux.repo`<br>`sudo zypper refresh`<br>`sudo zypper install quickshell` |
| NixOS / Nix | `nix profile install nixpkgs#quickshell` |
| Gentoo (GURU) | `sudo eselect repository enable guru`<br>`sudo emerge --sync guru`<br>`sudo emerge gui-apps/quickshell` |
| Guix | `guix install quickshell` |

On NixOS, prefer adding `pkgs.quickshell` to `environment.systemPackages` or
`home.packages`. On Gentoo, install `eselect-repository` before enabling GURU.

Depending on the distribution, install `qtsvg`, `qtimageformats`,
`qtmultimedia`, and `qt5compat` for SVG icons, additional image formats, media,
and blur effects.

To build Quickshell manually, follow the
[Quickshell build instructions](https://github.com/quickshell-mirror/quickshell/blob/master/BUILD.md).
