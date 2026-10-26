import Quickshell
import Quickshell.Io
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

    MangoState {
        id: mango
    }

    SystemStats {
        id: stats
    }

    VolumeState {
        id: volume
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
            top: 9
        }

        implicitHeight: 38
        color: "transparent"
        // exclusiveZone: 1
        // aboveWindows: true
        focusable: island.needsKeyboard

        mask: Region {
            x: Math.round(island.x)
            y: Math.round(island.y)
            width: Math.round(island.width)
            height: Math.round(island.height)
            radius: 17
        }

        Island {
            id: island
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            mango: mango
            stats: stats
            volume: volume
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
    }
}
