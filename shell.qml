//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
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
        WlrLayershell.keyboardFocus: (island.settingsOpen || island.wifiMenuOpen
            || island.bluetoothMenuOpen || island.powerMenuOpen || island.pinned)
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
