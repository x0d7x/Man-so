import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

Row {
    id: item

    property string itemType
    property var host

    spacing: 4

    Text {
        visible: item.itemType === "workspace"
        text: item.host ? item.host.workspaceText : ""
        color: item.host ? item.host.accentColor : "transparent"
        font.family: item.host ? item.host.monoFont : ""
        font.pixelSize: item.host ? Math.round(10 * item.host.fontScale) : 10
        font.weight: Font.DemiBold
    }

    IconImage {
        visible: item.itemType === "window" && item.host && item.host.appIconSource.length > 0
        source: item.host ? item.host.appIconSource : ""
        implicitSize: item.host ? Math.round(16 * item.host.fontScale) : 16
    }

    Text {
        visible: item.itemType === "layout"
        text: item.host ? item.host.layoutSymbol : ""
        color: item.host ? item.host.tertiaryColor : "transparent"
        font.family: item.host ? item.host.monoFont : ""
        font.pixelSize: item.host ? Math.round(9 * item.host.fontScale) : 9
        font.weight: Font.Bold
    }

    Text {
        visible: item.itemType === "cpu"
        text: "󰻠 " + (item.host && item.host.stats ? item.host.stats.cpuText : "--")
        color: item.host ? item.host.fgColor : "transparent"
        font.family: item.host ? item.host.monoFont : ""
        font.pixelSize: item.host ? Math.round(9 * item.host.fontScale) : 9
        font.weight: Font.Medium
    }

    Text {
        visible: item.itemType === "ram"
        text: "󰍛 " + (item.host && item.host.stats ? item.host.stats.memText : "--")
        color: item.host ? item.host.fgColor : "transparent"
        font.family: item.host ? item.host.monoFont : ""
        font.pixelSize: item.host ? Math.round(9 * item.host.fontScale) : 9
        font.weight: Font.Medium
    }

    Text {
        visible: item.itemType === "temp"
        text: "󰔏 " + (item.host && item.host.stats ? item.host.stats.tempText : "--")
        color: item.host ? item.host.fgColor : "transparent"
        font.family: item.host ? item.host.monoFont : ""
        font.pixelSize: item.host ? Math.round(9 * item.host.fontScale) : 9
        font.weight: Font.Medium
    }

    Text {
        visible: item.itemType === "battery"
        text: (item.host && item.host.stats ? item.host.stats.batteryIcon : "󰂎") + " "
            + (item.host && item.host.stats ? item.host.stats.batteryText : "--")
        color: item.host && item.host.batteryCriticalActive
            ? item.host.errorColor
            : (item.host && item.host.batteryWarningActive ? item.host.accentColor : item.host.fgColor)
        font.family: item.host ? item.host.monoFont : ""
        font.pixelSize: item.host ? Math.round(9 * item.host.fontScale) : 9
        font.weight: Font.Medium
    }

    Text {
        visible: item.itemType === "wifi"
        text: item.host && item.host.network ? item.host.network.icon : "󰤯"
        color: item.host && item.host.network && item.host.network.connected
            ? item.host.secondaryColor
            : item.host.mutedColor
        font.family: item.host ? item.host.monoFont : ""
        font.pixelSize: item.host ? Math.round(12 * item.host.fontScale) : 12
        font.weight: Font.Medium
    }

    Text {
        visible: item.itemType === "bluetooth"
        text: item.host && item.host.bluetooth ? item.host.bluetooth.icon : "󰂲"
        color: item.host && item.host.bluetooth && item.host.bluetooth.enabled
            ? (item.host.bluetooth.connectedCount > 0 ? item.host.secondaryColor : item.host.accentColor)
            : item.host.mutedColor
        font.family: item.host ? item.host.monoFont : ""
        font.pixelSize: item.host ? Math.round(12 * item.host.fontScale) : 12
        font.weight: Font.Medium
    }

    Text {
        visible: item.itemType === "power"
        text: item.host && item.host.power ? item.host.power.icon : "󰾅"
        color: item.host ? item.host.powerColor() : "transparent"
        font.family: item.host ? item.host.monoFont : ""
        font.pixelSize: item.host ? Math.round(12 * item.host.fontScale) : 12
        font.weight: Font.Medium
    }

    Text {
        visible: item.itemType === "volume"
        text: (item.host && item.host.volume ? item.host.volume.icon : "󰖁") + " "
            + (item.host && item.host.volume ? item.host.volume.levelText : "--")
        color: item.host && item.host.volume && item.host.volume.muted
            ? item.host.mutedColor
            : item.host.accentColor
        font.family: item.host ? item.host.monoFont : ""
        font.pixelSize: item.host ? Math.round(9 * item.host.fontScale) : 9
        font.weight: Font.DemiBold
    }

    Text {
        visible: item.itemType === "media"
        text: item.host && item.host.media && item.host.media.hasPlayer
            ? (item.host.media.isPlaying ? "󰏤" : "󰐊")
            : "󰎆"
        color: item.host && item.host.media && item.host.media.isPlaying
            ? item.host.accentColor
            : item.host.mutedColor
        font.family: item.host ? item.host.monoFont : ""
        font.pixelSize: item.host ? Math.round(12 * item.host.fontScale) : 12
        font.weight: Font.Medium
    }

    Row {
        visible: item.itemType === "notifications"
        spacing: 3

        Text {
            text: "󰂚"
            color: item.host && item.host.notifications && item.host.notifications.unreadCount > 0
                ? item.host.accentColor
                : item.host.fgColor
            font.family: item.host ? item.host.monoFont : ""
            font.pixelSize: item.host ? Math.round(12 * item.host.fontScale) : 12
            font.weight: Font.Medium
        }

        Text {
            visible: item.host && item.host.notifications && item.host.notifications.unreadCount > 0
            text: item.host ? item.host.notifications.unreadCount : ""
            color: item.host ? item.host.accentColor : "transparent"
            font.family: item.host ? item.host.monoFont : ""
            font.pixelSize: item.host ? Math.round(8 * item.host.fontScale) : 8
            font.weight: Font.Bold
        }
    }

    Row {
        visible: item.itemType === "tray"
        spacing: 3

        Repeater {
            model: SystemTray.items

            delegate: Image {
                required property var modelData
                width: item.host ? Math.round(15 * item.host.fontScale) : 15
                height: width
                source: item.host ? item.host.trayIconSource(modelData) : ""
                sourceSize.width: 16
                sourceSize.height: 16
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }
    }
}
