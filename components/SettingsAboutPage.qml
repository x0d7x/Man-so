import QtQuick
import QtQuick.Layouts

Item {
    id: page

    property var diagnostics
    property string monoFont
    property color fgColor
    property color mutedColor
    property color accentColor
    property color surfaceHighColor

    Flickable {
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: content.implicitHeight

        ColumnLayout {
            id: content
            width: parent.width
            spacing: 7

            RowLayout {
                spacing: 8

                Text {
                    text: "󰒓"
                    color: page.accentColor
                    font.family: page.monoFont
                    font.pixelSize: 24
                }

                Column {
                    spacing: 1
                    Text {
                        text: "man-qs"
                        color: page.fgColor
                        font.family: page.monoFont
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: "Dynamic Island for MangoWM"
                        color: page.mutedColor
                        font.family: page.monoFont
                        font.pixelSize: 9
                    }
                }
            }

            Item { implicitHeight: 3 }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "Quickshell"
                value: page.diagnostics ? page.diagnostics.quickshellVersion : "—"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "MangoWM"
                value: page.diagnostics ? page.diagnostics.mangoVersion : "—"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "System"
                value: page.diagnostics
                    ? page.diagnostics.osName + (page.diagnostics.kernelVersion.length > 0 ? " · " + page.diagnostics.kernelVersion : "")
                    : "—"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "Monitors"
                value: page.diagnostics ? page.diagnostics.monitorsText : "—"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "Keyboard"
                value: page.diagnostics ? page.diagnostics.keyboardLayout : "—"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "Notifications"
                value: "Quickshell NotificationServer"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "Audio"
                value: "PipeWire · pactl + wpctl"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "Media"
                value: "MPRIS + MPD"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }
        }
    }
}
