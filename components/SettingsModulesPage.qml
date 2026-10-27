import QtQuick
import QtQuick.Layouts

Item {
    id: page

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
            spacing: 6

            Text {
                text: "Island Modules"
                color: page.fgColor
                font.family: page.monoFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: "Choose which modules appear in the expanded dashboard. Temporary OSDs are unchanged."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 9
                wrapMode: Text.Wrap
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Workspace tags"
                description: "Show workspace chips in the dashboard header."
                checked: page.settings ? page.settings.showWorkspaceTags : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showWorkspaceTags = !page.settings.showWorkspaceTags
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Window information"
                description: "Show the active window icon and title."
                checked: page.settings ? page.settings.showWindowInfo : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showWindowInfo = !page.settings.showWindowInfo
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "System statistics"
                description: "Show CPU, memory, temperature, and battery."
                checked: page.settings ? page.settings.showSystemStats : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showSystemStats = !page.settings.showSystemStats
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Media card"
                description: "Show the now-playing dashboard card."
                checked: page.settings ? page.settings.showMedia : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showMedia = !page.settings.showMedia
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Volume"
                description: "Show the dashboard volume controls."
                checked: page.settings ? page.settings.showVolume : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showVolume = !page.settings.showVolume
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Notifications"
                description: "Show recent notifications and the notification center entry."
                checked: page.settings ? page.settings.showNotifications : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showNotifications = !page.settings.showNotifications
            }

            Item { implicitHeight: 2 }

            Rectangle {
                Layout.preferredWidth: 128
                Layout.preferredHeight: 28
                radius: 7
                color: restoreHover.hovered
                    ? Qt.rgba(page.accentColor.r, page.accentColor.g, page.accentColor.b, 0.2)
                    : Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.5)

                Text {
                    anchors.centerIn: parent
                    text: "RESTORE DEFAULTS"
                    color: restoreHover.hovered ? page.accentColor : page.mutedColor
                    font.family: page.monoFont
                    font.pixelSize: 7
                    font.weight: Font.Bold
                }

                HoverHandler {
                    id: restoreHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (page.settings) page.settings.resetModules()
                }
            }
        }
    }
}
