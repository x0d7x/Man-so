//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Wayland._IdleNotify
import QtQuick

import "components"
import "services"

ShellRoot {
    id: root

    property bool pinned: false

    readonly property var targetScreen: {
        const screens = Quickshell.screens;
        if (!screens || screens.length === 0)
            return null;

        for (let i = 0; i < screens.length; ++i) {
            if (screens[i].name === mango.focusedMonitor)
                return screens[i];
        }

        return screens[0];
    }

    MangoIpc {
        id: mangoIpc
    }

    MangoState {
        id: mango
        mangoIpc: mangoIpc
    }

    SystemStats {
        id: stats
        settings: settings
    }

    VolumeState {
        id: volume
        step: settings.volumeStep
        osdTimeout: settings.volumeOsdTimeout
    }

    BrightnessState {
        id: brightness
        osdTimeout: settings.brightnessOsdTimeout
    }

    DdcBrightnessState {
        id: ddcBrightness
        syncEnabled: settings.ddcSyncEnabled
        syncInterval: settings.ddcSyncInterval
    }

    NotificationState {
        id: notifications
        defaultTimeout: settings.notificationOsdTimeout
        maxHistory: settings.notificationHistoryLimit
    }

    PrivacyState {
        id: privacy
        enabled: settings.privacyEnabled
        microphoneEnabled: settings.privacyMicrophoneEnabled
        screenEnabled: settings.privacyScreenEnabled
    }

    MediaState {
        id: media
        hideDelay: settings.mediaOsdTimeout
    }

    DiagnosticsState {
        id: diagnostics
        network: network
        mangoIpc: mangoIpc
        keyboardState: keyboardLayout
    }

    SettingsState {
        id: settings
    }

    KeyboardLayoutState {
        id: keyboardLayout
        mangoIpc: mangoIpc
        osdEnabled: settings.showKeyboardOsd
        osdTimeout: settings.keyboardOsdTimeout
    }

    BluetoothState {
        id: bluetooth
    }

    NetworkState {
        id: network
    }

    PowerState {
        id: power
    }

    WallpaperState {
        id: wallpaper
        settings: settings
        mango: mango
    }

    WallpaperLayer {
        wallpaper: wallpaper
        settings: settings
    }

    WallpaperThumbnails {
        id: wallpaperThumbnails
    }

    WallpaperPicker {
        wallpaper: wallpaper
        settings: settings
        thumbnails: wallpaperThumbnails
        colors: colors
    }

    PolkitState {
        id: polkit
        enabled: settings.polkitAgentEnabled
    }

    LockState {
        id: lockScreen
        colors: colors
        settings: settings
    }

    IdleState {
        id: idle
        settings: settings
        lockScreen: lockScreen
        mangoIpc: mangoIpc
        media: media
    }

    // Idle monitors are created imperatively once settings are loaded: the idle
    // notification keeps the timeout it was created with, and monitors living in a
    // reload scope (Scope/Variants) never report idle. Creating them as direct
    // children of the shell root with the final timeout is what works.
    property var lockIdleMonitor: null
    property var displayIdleMonitor: null

    Component {
        id: lockIdleComponent

        IdleMonitor {
            enabled: true
            respectInhibitors: true

            onIsIdleChanged: {
                if (isIdle && idle.lockArmed)
                    idle.onLockIdle();
            }
        }
    }

    Component {
        id: displayIdleComponent

        IdleMonitor {
            enabled: true
            respectInhibitors: true

            onIsIdleChanged: {
                if (isIdle) {
                    if (idle.displayOffArmed)
                        idle.sleepDisplays();
                } else {
                    idle.wakeDisplays();
                }
            }
        }
    }

    function rearmIdle() {
        if (root.lockIdleMonitor) {
            root.lockIdleMonitor.destroy();
            root.lockIdleMonitor = null;
        }
        if (root.displayIdleMonitor) {
            root.displayIdleMonitor.destroy();
            root.displayIdleMonitor = null;
        }
        if (!settings.initialized)
            return;
        const lockMinutes = settings.idleLockMinutes;
        if (lockMinutes > 0)
            root.lockIdleMonitor = lockIdleComponent.createObject(root, { "timeout": lockMinutes * 60 });
        const offMinutes = settings.idleDisplayOffMinutes;
        if (offMinutes > 0)
            root.displayIdleMonitor = displayIdleComponent.createObject(root, { "timeout": offMinutes * 60 });
    }

    Connections {
        target: settings

        function onInitializedChanged() {
            root.rearmIdle();
        }

        function onIdleLockMinutesChanged() {
            root.rearmIdle();
        }

        function onIdleDisplayOffMinutesChanged() {
            root.rearmIdle();
        }
    }

    PowerActions {
        id: powerActions
        settings: settings
        lockScreen: lockScreen
        mangoIpc: mangoIpc
    }

    Colors {
        id: colors
    }

    PanelWindow {
        id: panel

        screen: root.targetScreen
        anchors {
            top: true
            left: true
            right: true
        }
        margins {
            top: 6
        }

        implicitHeight: Math.max(
            520,
            Math.min(
                root.targetScreen ? root.targetScreen.height - 12 : 900,
                Math.ceil(island.height * island.uiScale) + 12))
        color: "transparent"
        exclusiveZone: 34
        aboveWindows: true
        WlrLayershell.namespace: "maneso"
        WlrLayershell.keyboardFocus: (polkit.isActive || island.settingsOpen || island.wifiMenuOpen
            || island.bluetoothMenuOpen || island.powerMenuOpen || island.powerActionsOpen || island.pinned)
            ? WlrKeyboardFocus.Exclusive
            : (island.needsKeyboard ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None)

        mask: Region {
            x: Math.round(island.x + (island.width - island.width * island.uiScale) / 2)
            y: Math.round(island.y)
            width: Math.round(island.width * island.uiScale)
            height: Math.round(island.height * island.uiScale)
            radius: Math.round(island.cornerRadius * island.uiScale)
        }

        Island {
            id: island
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            mango: mango
            stats: stats
            volume: volume
            brightness: brightness
            ddcBrightness: ddcBrightness
            notifications: notifications
            media: media
            diagnostics: diagnostics
            settings: settings
            privacy: privacy
            keyboardLayout: keyboardLayout
            wallpaper: wallpaper
            polkit: polkit
            powerActions: powerActions
            idle: idle
            bluetooth: bluetooth
            network: network
            power: power
            colors: colors
            panelWindow: panel
            pinned: root.pinned
            onPinRequested: root.pinned = !root.pinned
            onExpandRequested: root.pinned = true
        }
    }

    IpcHandler {
        target: "power"

        function help(): string {
            return [
                "maneso power IPC",
                "",
                "  menu                    Open the island power menu (profiles + actions)",
                "  actions                 Open the actions-only menu (no profiles)",
                "  idle                    Toggle idle handling on/off (shows an OSD)",
                "  idleStatus              Print idle state",
                "  status                  Print idle and power state",
                "  help                    Show this help"
            ].join("\n");
        }

        function actions(): string {
            island.togglePowerActions();
            return island.powerActionsOpen ? "open" : "closed";
        }

        function idle(): string {
            if (!settings.initialized)
                return "settings not ready";
            settings.idleEnabled = !settings.idleEnabled;
            island.showIdleOsd(settings.idleEnabled);
            return settings.idleEnabled ? "on" : "off";
        }

        function idleStatus(): string {
            return "enabled=" + settings.idleEnabled
                + " lock=" + settings.idleLockMinutes + "m"
                + " displayOff=" + settings.idleDisplayOffMinutes + "m"
                + " lockArmed=" + idle.lockArmed
                + " displayArmed=" + idle.displayOffArmed
                + " suppressed=" + idle.suppressed
                + " displaysOff=" + idle.displaysOff;
        }

        function menu(): string {
            island.togglePowerMenu();
            return island.powerMenuOpen ? "open" : "closed";
        }

        function status(): string {
            return "lock=" + settings.idleLockMinutes + "m"
                + " displayOff=" + settings.idleDisplayOffMinutes + "m"
                + " suppressed=" + idle.suppressed
                + " displaysOff=" + idle.displaysOff
                + " lockArmed=" + idle.lockArmed
                + " displayArmed=" + idle.displayOffArmed
                + " pending=" + powerActions.pendingAction
                + " busy=" + powerActions.busy
                + " error=" + JSON.stringify(powerActions.lastError);
        }
    }

    IpcHandler {
        target: "lock"

        function help(): string {
            return [
                "maneso lock IPC",
                "",
                "  lock                    Lock the session now",
                "  status                  Print lock state",
                "  help                    Show this help",
                "",
                "Unlocking is deliberately not exposed: it requires the password"
            ].join("\n");
        }

        function lock(): string {
            lockScreen.lock();
            return "locking";
        }

        function status(): string {
            return "locked=" + lockScreen.locked
                + " secure=" + lockScreen.secure
                + " authenticating=" + lockScreen.authenticating
                + " error=" + JSON.stringify(lockScreen.errorText);
        }
    }

    IpcHandler {
        target: "wallpaper"

        function help(): string {
            return [
                "manēso wallpaper IPC",
                "",
                "Usage: qs -c maneso ipc call wallpaper <command> [args]",
                "",
                "  set <absolute-path>     Apply an image (queued; check status)",
                "  random                  Apply a random image from the directory",
                "  next                    Apply the next image in sorted order",
                "  previous                Apply the previous image in sorted order",
                "  reload                  Rescan the wallpaper directory",
                "  picker                  Open or close the wallpaper picker",
                "  status                  Print backend, directory, current image and errors",
                "  help                    Show this help"
            ].join("\n");
        }

        function set(path: string): string {
            return wallpaper.setPath(path) ? "queued" : "rejected: " + wallpaper.lastError;
        }

        function random(): string {
            return wallpaper.randomWallpaper() ? "queued" : "rejected: " + wallpaper.lastError;
        }

        function next(): string {
            return wallpaper.nextWallpaper() ? "queued" : "rejected: " + wallpaper.lastError;
        }

        function previous(): string {
            return wallpaper.previousWallpaper() ? "queued" : "rejected: " + wallpaper.lastError;
        }

        function reload(): string {
            wallpaper.refresh();
            return "reloading";
        }

        function picker(): string {
            wallpaper.togglePicker();
            return wallpaper.pickerOpen ? "open" : "closed";
        }

        function status(): string {
            return wallpaper.statusText();
        }
    }

    IpcHandler {
        target: "island"

        function help(): string {
            return [
                "manēso island IPC",
                "",
                "Usage: qs -c maneso ipc call island <command> [args]",
                "List the registered functions with: qs -c maneso ipc show",
                "",
                "ISLAND",
                "  toggle                  Toggle pinned/expanded state",
                "  expand                  Pin the island open",
                "  collapse                Unpin the island",
                "  setPinned <bool>        Set pinned state (true/false)",
                "  isPinned                Print pinned state",
                "  status                  Print \"pinned\" or \"collapsed\"",
                "  mode                    Print the current island mode",
                "  hovered                 Print pointer hover state",
                "  geometry                Print island and panel geometry",
                "  workspaces              Print workspace and overview state",
                "  reloadTheme             Reload Matugen colors",
                "",
                "NOTIFICATIONS",
                "  toggleNotifications     Toggle the notification-center popup",
                "  clearNotifications      Clear notification history",
                "  inhibitNotifications    Mute notification popups",
                "  uninhibitNotifications  Unmute notification popups",
                "  notificationsInhibited  Print inhibit state",
                "",
                "SETTINGS & PRIVACY",
                "  toggleSettings          Toggle the settings panel",
                "  privacyStatus           Print privacy session diagnostics",
                "  polkitStatus            Print polkit agent registration state",
                "",
                "HELP",
                "  help                    Show this help"
            ].join("\n");
        }

        function toggle(): void {
            root.pinned = !root.pinned;
            island.hoverDismissed = !root.pinned;
        }

        function expand(): void {
            root.pinned = true;
            island.hoverDismissed = false;
        }

        function collapse(): void {
            root.pinned = false;
            island.hoverDismissed = true;
        }

        function setPinned(value: bool): void {
            root.pinned = value;
            island.hoverDismissed = !root.pinned;
        }

        function isPinned(): bool {
            return root.pinned;
        }

        function status(): string {
            return root.pinned ? "pinned" : "collapsed";
        }

        function mode(): string {
            return island.mode;
        }

        function hovered(): bool {
            return island.pointerHovered;
        }

        function geometry(): string {
            const rect = panel.itemRect(island);
            return Math.round(rect.x) + "," + Math.round(rect.y) + "," + Math.round(rect.width) + "," + Math.round(rect.height)
                + " window=" + Math.round(panel.width) + "x" + Math.round(panel.height)
                + " island=" + Math.round(island.x) + "," + Math.round(island.y)
                + " dpr=" + panel.devicePixelRatio;
        }

        function workspaces(): string {
            return "overview=" + (island.overviewActive ? "true" : "false")
                + " label=" + island.overviewLabel
                + " text=" + island.workspaceText
                + " active=" + island.activeTags.join(",");
        }

        function reloadTheme(): void {
            colors.reloadColors();
        }

        function toggleNotifications(): void {
            island.toggleNotificationCenter();
        }

        function clearNotifications(): void {
            notifications.clearAll();
        }

        function inhibitNotifications(): void {
            notifications.setInhibited(true);
        }

        function uninhibitNotifications(): void {
            notifications.setInhibited(false);
        }

        function notificationsInhibited(): bool {
            return notifications.inhibited;
        }

        function toggleSettings(): void {
            island.toggleSettings();
        }

        function polkitStatus(): string {
            return "enabled=" + polkit.enabled
                + " registered=" + polkit.registered
                + " active=" + polkit.isActive
                + " action=" + polkit.actionId;
        }

        function privacyStatus(): string {
            return "microphoneKnown=" + privacy.microphoneKnown
                + " microphoneActive=" + privacy.microphoneActive
                + " sessions=" + privacy.microphoneSessionCount
                + " apps=" + privacy.microphoneApps.join(",")
                + " screenKnown=" + privacy.screenKnown
                + " screenActive=" + privacy.screenActive
                + " screenSessions=" + privacy.screenSessionCount
                + " screenApps=" + privacy.screenApps.join(",")
                + " micError=" + privacy.lastError
                + " screenError=" + privacy.screenError;
        }

    }
}
