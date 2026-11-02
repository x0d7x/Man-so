# Changelog

All notable changes to manēso. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions use [Semantic Versioning](https://semver.org/).

## [0.6.0] - 2026-11-15

### Added

- Session lock screen through `ext-session-lock-v1`: one opaque surface per
  screen, a PAM login conversation, and an error path that keeps the session
  locked.
- Lock page in the settings centre, with blur, darkening, clock size, time and
  date formats, media controls, battery, avatar, Caps Lock warning, an attempt
  counter and a shake on failed authentication.
- Polkit authentication agent prompting inside the island, registered only
  while enabled.
  ![polkit-pic](https://i.imgur.com/uyNk3VA.png)

- Power menu with lock, suspend, logout, reboot and shutdown, each toggleable,
  with inline confirmation and a suspend that waits for a secure lock.
  ![power-menu](https://imgur.com/GCRSINn.png)

- Idle handling through `ext-idle-notify-v1` with inhibitors respected, locking
  the session and turning screens off on timeout, plus an optional indicator
  when idle is off.
- Actions-only actions panel sharing its component with the power menu:
  exclusive keyboard focus, rows or grid layout, adjustable width and height.
- Wallpaper state service with `awww` and command backends, Matugen and Veila
  hooks, rotation, random/next/previous, last-path persistence and IPC.
- In-process Quickshell layer-shell wallpaper backend, one click-through
  surface per screen, with crossfade and fill/fit/stretch/center/tile modes.
- Full-screen wallpaper picker in carousel, grid and spotlight layouts, backed
  by an `ffmpeg` thumbnail cache.
- Wallpaper settings page covering backend, folder, layout, target, command
  template, transitions, rotation, hooks and shuffle/reload/restore, plus
  reusable choice and text row widgets.

### Changed

- Lock settings moved out of the Power page into their own page.
- Settings schema bumped to 26, migrating later page indices.
- MangoWM overview state is shown instead of workspace 0.
- Wallpaper rotation slider widened to the documented 0-1440 range.
- Logind session panel and its IPC dropped from the power menu.

### Fixed

- Wallpaper stepping and rotation skip unreadable files, resuming from the
  failed file rather than the current one.
- Wallpapers are restored on hotplug for the `awww` backend.
- The wallpaper thumbnail service no longer respawns its cache listing
  forever, and transient notification and media images are no longer cached.

### Docs

- Wallpaper settings, picker and IPC, the lock screen and how to replace
  another locker, idle, the power menu and the session IPC documented in
  `CONFIGURATION.md`.
