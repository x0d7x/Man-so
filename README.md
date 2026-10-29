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

Settings are stored at `$XDG_CONFIG_HOME/maneso/settings.json`
(`~/.config/maneso/settings.json` by default) and can be changed from the
in-island settings panel. Changes are saved automatically.

On first launch, an existing `~/.config/man-qs/settings.json` is copied to the
new location. The original file is left untouched.

### General

| Key                 | Description                             | Default   | Range / values       |
| ------------------- | --------------------------------------- | --------- | -------------------- |
| `expansionMode`     | How the collapsed island expands        | `"hover"` | `"hover"`, `"click"` |
| `animationDuration` | Expansion and collapse animation length | `220`     | 80–600 ms, step 10   |

### Appearance

| Key                 | Description                    | Default                          | Range / values            |
| ------------------- | ------------------------------ | -------------------------------- | ------------------------- |
| `fontFamily`        | Font family used by the island | `"JetBrainsMono Nerd Font Mono"` | Any installed font family |
| `fontSize`          | Base font size                 | `11`                             | 9–13 px                   |
| `uiScale`           | Overall UI scale               | `100`                            | 85–115%, step 5           |
| `backgroundOpacity` | Island background opacity      | `100`                            | 40–100%, step 5           |
| `cornerRadius`      | Island corner radius           | `17`                             | 8–32 px                   |
| `borderVisible`     | Show the island outline        | `true`                           | `true`, `false`           |
| `borderWidth`       | Outline thickness              | `1`                              | 1–4 px                    |

### Module visibility

| Key                      | Description                                                 | Default |
| ------------------------ | ----------------------------------------------------------- | ------- |
| `showWorkspaceTags`      | Show workspace chips in the dashboard header                | `true`  |
| `showWindowInfo`         | Show the active window icon and title                       | `true`  |
| `showSystemStats`        | Show CPU, memory, temperature, and battery statistics       | `true`  |
| `showMedia`              | Show the now-playing media card                             | `true`  |
| `showVolume`             | Show the dashboard volume controls                          | `true`  |
| `showBrightness`         | Show the internal display brightness slider                 | `true`  |
| `showExternalBrightness` | Show the DDC/CI external monitor brightness slider          | `true`  |
| `showNotifications`      | Show recent notifications and the notification center entry | `true`  |
| `showNetworkName`        | Show the active Wi-Fi network name                          | `true`  |
| `showCpuStat`            | Show CPU usage in the statistics row                        | `true`  |
| `showRamStat`            | Show memory usage in the statistics row                     | `true`  |
| `showTempStat`           | Show temperature in the statistics row                      | `true`  |
| `showBatteryStat`        | Show battery state in the statistics row                    | `true`  |
| `showMediaArtwork`       | Show album artwork in the media card and OSD                | `true`  |
| `showMediaProgress`      | Show seek position and the playback progress bar            | `true`  |
| `showNotificationImages` | Show image attachments in notification cards                | `true`  |
| `showBluetoothStatus`    | Show the Bluetooth status label                             | `true`  |

### Module details

| Key                        | Description                                                          | Default | Range / values           |
| -------------------------- | -------------------------------------------------------------------- | ------- | ------------------------ |
| `volumeStep`               | Volume change per step                                               | `2`     | 1–10%                    |
| `volumeOsdTimeout`         | Volume OSD duration                                                  | `1500`  | 800–4000 ms, step 100    |
| `brightnessOsdTimeout`     | Brightness OSD duration                                              | `1500`  | 800–4000 ms, step 100    |
| `ddcSyncEnabled`           | Poll external monitors for changes made with their physical controls | `true`  | `true`, `false`          |
| `ddcSyncInterval`          | DDC/CI polling interval                                              | `5000`  | 2000–15000 ms, step 1000 |
| `mediaOsdTimeout`          | Media OSD duration                                                   | `4000`  | 1000–10000 ms, step 100  |
| `notificationOsdTimeout`   | Notification OSD duration                                            | `6000`  | 2200–12000 ms, step 100  |
| `notificationHistoryLimit` | Number of notifications kept in history                              | `50`    | 10–100, step 5           |

### Collapsed island

| Key                    | Description                                     | Default    | Range / values     |
| ---------------------- | ----------------------------------------------- | ---------- | ------------------ |
| `collapsedItems`       | Items shown next to the clock, in display order | `["time"]` | Array of item keys |
| `collapsedItemSpacing` | Spacing between collapsed items                 | `4`        | 0–12 px            |
| `collapsedPadding`     | Horizontal padding inside the collapsed pill    | `14`       | 8–24 px            |

Available `collapsedItems` keys are `time`, `workspace`, `window`, `layout`,
`cpu`, `ram`, `temp`, `battery`, `wifi`, `bluetooth`, `power`, `volume`,
`brightness`, `externalBrightness`, `media`, `notifications`, and `tray`.
The clock is always included and cannot be removed.

### Power

| Key                        | Description                     | Default | Range / values       |
| -------------------------- | ------------------------------- | ------- | -------------------- |
| `cpuRefreshInterval`       | CPU statistics refresh interval | `300`   | 250–2000 ms, step 50 |
| `batteryWarningThreshold`  | Battery warning level           | `20`    | 5–50%, step 5        |
| `batteryCriticalThreshold` | Battery critical level          | `10`    | 1–20%                |

### MangoWM

| Key                       | Description                                                 | Default | Range / values                    |
| ------------------------- | ----------------------------------------------------------- | ------- | --------------------------------- |
| `workspaceVisibility`     | Which workspaces appear in the island                       | `"all"` | `"all"`, `"occupied"`, `"active"` |
| `showOccupiedIndicator`   | Show a dot under workspaces containing clients              | `true`  | `true`, `false`                   |
| `includeUrgentWorkspaces` | Keep urgent workspaces visible in Occupied and Active modes | `true`  | `true`, `false`                   |

### Keyboard

| Key                  | Description                                  | Default | Range / values        |
| -------------------- | -------------------------------------------- | ------- | --------------------- |
| `showKeyboardOsd`    | Show an OSD when the keyboard layout changes | `true`  | `true`, `false`       |
| `keyboardOsdTimeout` | Keyboard OSD duration                        | `1500`  | 800–4000 ms, step 100 |

### Privacy

| Key                        | Description                                           | Default |
| -------------------------- | ----------------------------------------------------- | ------- |
| `privacyEnabled`           | Master switch for privacy monitoring and indicators   | `true`  |
| `privacyMicrophoneEnabled` | Show microphone capture activity                      | `true`  |
| `privacyScreenEnabled`     | Show screen-sharing and recording activity            | `true`  |
| `privacyShowCollapsed`     | Show the microphone indicator in the collapsed island | `true`  |

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
