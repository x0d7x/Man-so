<table>
  <tr>
    <td width="148" valign="middle">
      <img src="docs/logo.jpeg" alt="manēso logo" width="128">
    </td>
    <td valign="middle">
      <h1>manēso</h1>
      <p><strong>manēso — A Dynamic Island for MangoWM</strong><br>
      <strong>Your desktop, in motion.</strong><br>
      A modern, animated Dynamic Island for MangoWM on Wayland. Built with Quickshell and QML.</p>
    </td>
  </tr>
</table>

![Demo](docs/demo.gif)

## Features

- Animated island with hover or click expansion
- Workspace tags, MangoWM overview awareness, focused window, and keyboard layout indicators
- Media controls via MPRIS and MPD
- Volume, brightness, and keyboard-layout on-screen displays
- Notification center with history and grouping
- System tray, privacy indicators, and system statistics
- Bluetooth, network, and power status
- Built-in settings panel
- Optional polkit authentication agent that prompts inside the island
- Session lock screen on `ext-session-lock-v1` with PAM authentication
- Wallpaper manager: awww, command or in-process layer backend, rotation,
  Matugen and Veila hooks, and a picker with carousel, grid and spotlight layouts
- Matugen color integration
- IPC commands for scripting and keybindings

## Requirements

- MangoWM on Wayland
- [Quickshell](https://quickshell.org/) with Qt 6 QML
- `wpctl` for PipeWire volume control
- `brightnessctl` for internal display brightness
- `ddcutil` for external display brightness
- `ffmpeg` for extracting MPD artwork and picker thumbnails
- `awww` (optional) for the awww wallpaper backend

These tools are only needed for the features that use them. The diagnostics page
reports any missing tools, including `notify-send` if it is not installed.

## Installing Quickshell

### Arch Linux

```sh
sudo pacman -S quickshell
```

For the latest git version from the AUR:

```sh
yay -S quickshell-git
```

The AUR command assumes `yay`; substitute your preferred AUR helper.

For other distributions and manual build instructions, see [INSTALL.md](INSTALL.md).

Depending on your setup, install `qtsvg`, `qtimageformats`, `qtmultimedia`, and
`qt5compat` for SVG icons, additional image formats, media, and blur effects.

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
qs -c maneso ipc show                    # list registered functions
qs -c maneso ipc call island help        # human-readable command list
qs -c maneso ipc call island toggle
qs -c maneso ipc call island status
qs -c maneso ipc call island workspaces  # workspace index or overview state
qs -c maneso ipc call island toggleNotifications
qs -c maneso ipc call island toggleSettings
qs -c maneso ipc call island polkitStatus  # agent registration and active request
```

The lock screen has its own target. Unlocking is intentionally not exposed, as
that would bypass authentication:

```sh
qs -c maneso ipc call lock lock      # lock now
qs -c maneso ipc call lock status    # locked, secure, authenticating, error
```

The wallpaper manager has its own target:

```sh
qs -c maneso ipc call wallpaper help
qs -c maneso ipc call wallpaper status     # backend, folder, count, current image
qs -c maneso ipc call wallpaper set /path/to/image.png
qs -c maneso ipc call wallpaper random
qs -c maneso ipc call wallpaper next       # also: previous
qs -c maneso ipc call wallpaper reload     # rescan the folder
qs -c maneso ipc call wallpaper picker     # open or close the picker
```

If you launch the configuration with `qs -p`, pass the same path to the IPC
command instead, for example
`qs -p /path/to/maneso ipc call island toggle`.

## Naming

- User-facing name: **manēso**
- ASCII identifier: **maneso**

## License

manēso is released under the [MIT License](LICENSE).
