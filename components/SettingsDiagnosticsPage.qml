import QtQuick
import QtQuick.Layouts

Item {
    id: page

    property var diagnostics
    property var settings
    property string monoFont
    property color fgColor
    property color mutedColor
    property color accentColor
    property color onAccentColor
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
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Diagnostics"
                    color: page.fgColor
                    font.family: page.monoFont
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: 62
                    Layout.preferredHeight: 24
                    radius: 7
                    color: refreshMouse.containsMouse ? page.accentColor : Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.5)

                    Text {
                        anchors.centerIn: parent
                        text: "REFRESH"
                        color: refreshMouse.containsMouse ? page.onAccentColor : page.mutedColor
                        font.family: page.monoFont
                        font.pixelSize: 7
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (page.diagnostics)
                                page.diagnostics.refresh();
                        }
                    }
                }
            }

            Item { implicitHeight: 3 }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "Settings file"
                value: page.settings ? page.settings.configPath : "—"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "Settings state"
                value: page.settings
                    ? (page.settings.lastError.length > 0 ? page.settings.lastError : (page.settings.initialized ? "Loaded" : "Loading"))
                    : "—"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "Tools"
                value: page.diagnostics ? page.diagnostics.toolStatus : "—"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "Backlight"
                value: page.diagnostics ? page.diagnostics.backlightStatus : "—"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "Screens"
                value: page.diagnostics ? page.diagnostics.monitorsText : "—"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "Keyboard layout"
                value: page.diagnostics ? page.diagnostics.keyboardLayout : "—"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "Notification daemon"
                value: "Quickshell"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "Volume backend"
                value: "PipeWire · pactl subscribe + wpctl"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "MPD socket"
                value: page.diagnostics ? page.diagnostics.mpdSocket : "—"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }

            SettingsInfoRow {
                Layout.fillWidth: true
                label: "Media backend"
                value: "MPRIS + MPD"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                surfaceHighColor: page.surfaceHighColor
            }
        }
    }
}
