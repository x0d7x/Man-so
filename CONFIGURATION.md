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

### Lock screen

The lock screen has no settings of its own. It uses `ext-session-lock-v1`, so the
compositor owns the lock: while it is active the session is covered on every
output, and only a successful PAM authentication clears it.

| Command                                  | Effect                    |
| ---------------------------------------- | ------------------------- |
| `qs -c maneso ipc call lock lock`        | Lock the session now      |
| `qs -c maneso ipc call lock status`      | Print lock state          |

Unlocking is deliberately **not** available over IPC, since anything able to
reach the socket could otherwise bypass authentication. The password prompt is
the only way out.

#### Appearance

| Key                     | Description                              | Default | Range / values |
| ----------------------- | ---------------------------------------- | ------- | -------------- |
| `lockBlurEnabled`       | Blur the wallpaper behind the prompt     | `true`  | `true`, `false` |
| `lockBlurAmount`        | Blur strength                            | `45`    | 0–100%         |
| `lockDim`               | Darkening applied over the background    | `55`    | 0–90%          |
| `lockClockScale`        | Clock and date size                      | `100`   | 60–160%        |
| `lockShowClock`         | Show the large clock                     | `true`  | `true`, `false` |
| `lockShowDate`          | Show the date under the clock            | `true`  | `true`, `false` |
| `lockShowScreenLabel`   | Show monitor name and lock state         | `false` | `true`, `false` |
| `lockClockFormat`       | Time format                              | `"24h"` | `"24h"`, `"12h"` |
| `lockDateFormat`        | Qt date pattern                          | `"dddd, d MMMM"` | any pattern, up to 40 chars |
| `lockShowMedia`         | Track title and playback buttons         | `true`  | `true`, `false` |
| `lockShowBattery`       | Battery percentage and charging state    | `true`  | `true`, `false` |
| `lockShowAvatar`        | Account name and avatar                  | `true`  | `true`, `false` |
| `lockShowCapsLock`      | Warn while Caps Lock is on               | `true`  | `true`, `false` |
| `lockShowAttempts`      | Count failed attempts                    | `true`  | `true`, `false` |
| `lockAnimateFailure`    | Shake the prompt after a wrong password  | `true`  | `true`, `false` |

These live on their own **Lock** page in the settings panel, and every one of them
can be switched off, so the lock screen can be as bare as a password field or a
full dashboard.

The Caps Lock warning reads the keyboard LED at
`/sys/class/leds/*::capslock/brightness`. Wayland has no keyboard-state protocol,
so on hardware without that LED the warning simply stays hidden.

Media controls use the same MPRIS service as the island, so they are inactive
when nothing is playing.

The password field has an eye button that reveals what you typed; the revealed
state is cleared as soon as the password is submitted, the field is cleared with
Esc, or the lock ends.

Authentication uses the `login` PAM stack (`/etc/pam.d/login`), the same one
other lock screens use, so failed attempts are counted by `pam_faillock`.

#### Replacing another locker

Only one session lock can be held at a time. If you already run a locker such as
Veila, stop its lock and idle services before using this one, otherwise the
second lock request is ignored:

```sh
systemctl --user disable --now veila-idle.service
```

Veila's idle service is also what locks on suspend; if you want manēso to take
over that role, point the idle trigger at `qs -c maneso ipc call lock lock`.

#### If manēso dies while locked

The compositor keeps the session covered with a blank screen, so nothing is
exposed. The dead client's lock is released, which means a restarted manēso can
take the lock again and unlock normally. If the compositor does not allow a new
lock, recover from a TTY by restarting the compositor.

The lock background is `~/.cache/veila/wallpaper.jpg`, kept in sync by the
wallpaper hooks, and falls back to a plain dark screen when that file is absent.

### Idle

| Key                       | Description                                   | Default | Range / values |
| ------------------------- | --------------------------------------------- | ------- | -------------- |
| `idleLockMinutes`         | Lock the session after this much idle time    | `5`     | 0–240, 0 = off |
| `idleDisplayOffMinutes`   | Turn the screens off after this much idle     | `10`    | 0–240, 0 = off |
| `idleSuppressOnMedia`     | Pause both timers while media is playing      | `true`  | `true`, `false` |
| `showIdleOffIcon`         | Show an indicator when both timers are off    | `false` | `true`, `false` |

Idle detection uses `ext-idle-notify-v1` with inhibitors respected, so fullscreen
video and anything holding an idle inhibitor keep the session awake. Screens are
turned off through MangoWM (`dispatch sleep_monitor` / `wakeup_monitor`).

Locking goes through the session lock screen, so it only works while that is
available. If you already run another idle daemon (for example
`veila-idle.service`), disable it, or both will try to lock.

### Power menu

| Key                    | Description                                | Default |
| ---------------------- | ------------------------------------------ | ------- |
| `powerRequireConfirm`  | Ask before suspend, logout, reboot, shutdown | `true` |
| `powerShowLock`        | Show Lock in the power menu                | `true`  |
| `powerShowSuspend`     | Show Suspend                               | `true`  |
| `powerShowLogout`      | Show Logout                                | `true`  |
| `powerShowReboot`      | Show Reboot                                | `true`  |
| `powerShowShutdown`    | Show Shutdown                              | `true`  |
| `powerActionsLayout`   | Look of the actions list                   | `"rows"` | `"rows"`, `"grid"` |
| `powerActionsWidth`    | Actions panel width                        | `380`   | 240–640 px, step 10 |
| `powerActionsHeight`   | Actions panel height                       | `316`   | 120–640 px, step 10 |

Suspend locks the session first and waits until the compositor reports the lock
as secure; if that does not happen within three seconds the suspend is cancelled
rather than sleeping with an unlocked session.

The actions-only menu has keyboard navigation: arrows or `h`/`l` move one entry,
`j`/`k` and up/down move one row (three entries per row in grid mode), Enter or
Space runs the selected action, and Esc closes the menu. The panel takes
exclusive keyboard focus while it is open.

```sh
qs -c maneso ipc call power menu     # power menu (profiles + actions)
qs -c maneso ipc call power actions  # actions only, no profiles
qs -c maneso ipc call power status   # idle timers, displays, pending action
```

The actions-only menu (no power profiles) and the idle switch are also available
over IPC:

```sh
qs -c maneso ipc call power actions     # lock/suspend/logout/reboot/shutdown only
qs -c maneso ipc call power idle        # toggle idle handling, shows an OSD
qs -c maneso ipc call power idleStatus  # timers, armed state, display state
```

`power idle` flips `idleEnabled` and shows an "IDLE ON"/"IDLE OFF" OSD in the
island. While idle is disabled the settings entries stay as they are, so turning
it back on restores the previous timers.
