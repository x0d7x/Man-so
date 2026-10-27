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

        implicitHeight: 520
        color: "transparent"
        exclusiveZone: 34
        aboveWindows: true
        WlrLayershell.namespace: "maneso"
        WlrLayershell.keyboardFocus: island.settingsOpen
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
            bluetooth: bluetooth
            network: network
            power: power
            colors: colors
            panelWindow: panel
            pinned: root.pinned
            onPinRequested: root.pinned = !root.pinned
        }
    }

    IpcHandler {
        target: "island"

        function toggle(): void {
            root.pinned = !root.pinned;
        }

        function expand(): void {
            root.pinned = true;
        }

        function collapse(): void {
            root.pinned = false;
        }

        function setPinned(value: bool): void {
            root.pinned = value;
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

        function reloadTheme(): void {
            colors.reloadColors();
        }

        function toggleNotifications(): void {
            island.toggleNotificationCenter();
        }

        function clearNotifications(): void {
            notifications.clearAll();
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
