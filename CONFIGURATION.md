# Configuration

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

### Dashboard

| Key                         | Description                                         | Default | Range / values      |
| --------------------------- | --------------------------------------------------- | ------- | ------------------- |
| `dashboardWidth`            | Width of the expanded dashboard                     | `420`   | 340–600 px, step 10 |
| `dashboardMaxHeight`        | Max dashboard height as a percentage of the screen  | `100`   | 40–100%, step 5     |
| `dashboardPadding`          | Inner padding of the dashboard                      | `14`    | 8–24 px             |
| `dashboardSpacing`          | Spacing between dashboard sections                  | `10`    | 4–18 px             |
| `dashboardNotificationRows` | Notification rows kept visible before scrolling     | `4`     | 1–8 rows            |
| `dashboardSeparators`       | Draw divider lines between dashboard sections       | `true`  | `true`, `false`     |
| `dashboardShowTray`         | Show system tray icons in the dashboard header      | `true`  | `true`, `false`     |
| `dashboardTrayLimit`        | Maximum number of tray icons shown                  | `3`     | 1–6                 |

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
| `showUnreadBell`         | Show a bell in the collapsed island on new notifications | `true`  |
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

Available `collapsedItems` keys are `time`, `date`, `workspace`, `window`,
`layout`, `cpu`, `ram`, `temp`, `battery`, `wifi`, `bluetooth`, `power`,
`volume`, `brightness`, `externalBrightness`, `media`, `notifications`, and
`tray`. The clock is always included and cannot be removed.

### Date

| Key             | Description                              | Default    | Range / values                          |
| --------------- | ---------------------------------------- | ---------- | --------------------------------------- |
| `dateFormat`    | Qt date format pattern for the date item | `"dd MMM"` | Any Qt date pattern, e.g. `ddd dd MMM`  |
| `dateUppercase` | Render the date in capitals              | `false`    | `true`, `false`                         |
| `dateAccent`    | Use the accent color for the date        | `false`    | `true`, `false`                         |
| `datePill`      | Give the date a subtle pill background   | `true`     | `true`, `false`                         |

Add `date` to `collapsedItems` to show it; use the Date section in
Settings → Island to pick a format preset and style.

### Power

| Key                        | Description                     | Default | Range / values       |
| -------------------------- | ------------------------------- | ------- | -------------------- |
| `cpuRefreshInterval`       | CPU statistics refresh interval | `300`   | 250–2000 ms, step 50 |
| `batteryWarningThreshold`  | Battery warning level           | `20`    | 5–50%, step 5        |
| `batteryCriticalThreshold` | Battery critical level          | `10`    | 1–20%                |

### MangoWM

| Key                       | Description                                                                   | Default      | Range / values                    |
| ------------------------- | ----------------------------------------------------------------------------- | ------------ | --------------------------------- |
| `workspaceVisibility`     | Which workspaces appear in the island                                         | `"all"`      | `"all"`, `"occupied"`, `"active"` |
| `overviewLabel`           | Text shown instead of the workspace index while MangoWM's overview is open     | `"overview"` | any text, up to 24 characters     |
| `showOccupiedIndicator`   | Show a dot under workspaces containing clients                                | `true`       | `true`, `false`                   |
| `includeUrgentWorkspaces` | Keep urgent workspaces visible in Occupied and Active modes                   | `true`       | `true`, `false`                   |

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

### Wallpaper

The wallpaper section covers the backend, the folder to scan, transitions,
rotation, post-apply hooks, and the picker. It is not a replacement for
matuwall: matuwall keeps working, and its `on_apply` hooks should be removed if
manēso owns the apply pipeline, so Matugen does not run twice.

#### Backend and layout

| Key                     | Description                                              | Default                    | Range / values                              |
| ----------------------- | -------------------------------------------------------- | -------------------------- | ------------------------------------------- |
| `wallpaperBackend`      | How the wallpaper is drawn                               | `"awww"`                   | `"awww"`, `"command"`, `"quickshell"`       |
| `wallpaperDirectory`    | Folder scanned for images (one level, no recursion)      | `"~/Documents/wallpaper"`  | absolute or `~/…` path                      |
| `wallpaperFit`          | How the image fills the screen                           | `"fill"`                   | `"fill"`, `"fit"`, `"stretch"`, `"center"`, `"tile"` |
| `wallpaperTarget`       | Apply to every output or only the focused one (awww)     | `"all"`                    | `"all"`, `"focused"`                        |
| `wallpaperCommand`      | Command template for the `command` backend               | `""`                       | text containing `{path}`                    |
| `wallpaperLayer`        | Layer used by the `quickshell` backend                   | `"background"`             | `"background"`, `"bottom"`                  |

`awww` renders through the running awww daemon and survives manēso restarts.
`command` runs your template with `{path}` replaced by the quoted image path;
exit code 0 means success. `quickshell` draws the image in a click-through layer
surface per screen, inside manēso itself.

`tile` is only exact for the `quickshell` backend; awww has no tile mode, so it
centres the image at native size instead.

#### Transitions and rotation

| Key                             | Description                                       | Default  | Range / values                                          |
| ------------------------------- | ------------------------------------------------- | -------- | ------------------------------------------------------- |
| `wallpaperTransition`           | awww transition effect                            | `"fade"` | `"none"`, `"simple"`, `"fade"`, `"wipe"`, `"grow"`, `"random"` |
| `wallpaperTransitionDuration`   | Transition length in seconds                      | `1`      | 0–5                                                     |
| `wallpaperRotateMinutes`        | Shuffle interval; `0` disables rotation           | `0`      | 0–1440                                                  |

Rotation picks a random image and skips unreadable files. Stepping with
`next`/`previous` also skips unreadable files, up to ten in a row, then stops
with the last error instead of looping.

#### Hooks

| Key                     | Description                                                | Default |
| ----------------------- | ---------------------------------------------------------- | ------- |
| `wallpaperMatugen`      | Run `matugen image <path>` after each change               | `true`  |
| `wallpaperVeilaSync`    | Copy the image to `~/.cache/veila/wallpaper.jpg` for Veila | `true`  |
| `wallpaperHooks`        | Extra commands run after each change                       | `[]`    |

Each entry in `wallpaperHooks` is run through `sh -c` with `{path}` replaced by
the quoted image path. At most eight hooks are kept.

#### Picker

| Key                        | Description                                        | Default      | Range / values                          |
| -------------------------- | -------------------------------------------------- | ------------ | --------------------------------------- |
| `wallpaperPickerLayout`    | Layout used by the picker                          | `"carousel"` | `"carousel"`, `"grid"`, `"spotlight"`   |
| `wallpaperPickerOpacity`   | Picker panel background opacity                    | `97`         | 40–100%                                 |
| `wallpaperPickerVimKeys`   | Add `h`/`j`/`k`/`l`, `g`/`G` and `q` bindings      | `false`      | `true`, `false`                         |
| `wallpaperTileRadius`      | Tile corner radius                                 | `18`         | 0–64 px                                 |
| `wallpaperTileBorderWidth` | Border width of the focused tile                   | `2`          | 0–6 px                                  |
| `wallpaperTileBorderColor` | Border colour; empty follows the theme accent      | `""`         | `#rgb`, `#rrggbb`, `#rrggbbaa`, or empty |
| `wallpaperZoomPercent`     | How much the focused tile grows in the carousel    | `8`          | 0–30%                                   |

Thumbnails are generated on demand with `ffmpeg` and cached in
`$XDG_CACHE_HOME/maneso/wallpaper-thumbs`, capped at 600 files (oldest removed
first).

### Polkit

| Key                   | Description                                          | Default |
| --------------------- | ---------------------------------------------------- | ------- |
| `polkitAgentEnabled`  | Register manēso as the polkit authentication agent   | `false` |

When enabled, privilege requests (`pkexec`, graphical package installs, and
anything else that needs `org.freedesktop.policykit.exec` style authorisation)
prompt for a password inside the island instead of a separate dialog.

Only one agent should be registered per session. If another agent is started
(for example `polkit-gnome-authentication-agent-1` from your compositor's
autostart), remove it, otherwise the two compete and the request may be handled
by the wrong one.

The password is passed straight to polkit, is never written to disk, and is
cleared from memory when the request is submitted, cancelled, or closed. Failed
attempts are counted by `pam_faillock`, so repeated wrong passwords can lock
the account for a while, exactly as with any other polkit agent.
