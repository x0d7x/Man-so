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
            spacing: 8

            Text {
                text: "Dashboard"
                color: page.fgColor
                font.family: page.monoFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: "Size, density, and header of the expanded dashboard. Module visibility lives in the Modules page."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 9
                wrapMode: Text.Wrap
            }

            Text {
                text: "LAYOUT"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Dashboard width"
                value: page.settings ? page.settings.dashboardWidth : 420
                from: 340
                to: 600
                step: 10
                suffix: " px"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.dashboardWidth = value;
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Max height"
                value: page.settings ? page.settings.dashboardMaxHeight : 100
                from: 40
                to: 100
                step: 5
                suffix: "%"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.dashboardMaxHeight = value;
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Padding"
                value: page.settings ? page.settings.dashboardPadding : 14
                from: 8
                to: 24
                step: 1
                suffix: " px"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.dashboardPadding = value;
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Section spacing"
                value: page.settings ? page.settings.dashboardSpacing : 10
                from: 4
                to: 18
                step: 1
                suffix: " px"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.dashboardSpacing = value;
                }
            }

            Text {
                text: "NOTIFICATIONS"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Visible notification rows"
                value: page.settings ? page.settings.dashboardNotificationRows : 4
                from: 1
                to: 8
                step: 1
                suffix: " rows"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.dashboardNotificationRows = value;
                }
            }

            Text {
                text: "HEADER"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Tray icons"
                description: "Show system tray icons in the dashboard header."
                checked: page.settings ? page.settings.dashboardShowTray : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.dashboardShowTray = !page.settings.dashboardShowTray;
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Tray icons shown"
                value: page.settings ? page.settings.dashboardTrayLimit : 3
                from: 1
                to: 6
                step: 1
                suffix: " icons"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.dashboardTrayLimit = value;
                }
            }

            Text {
                text: "SURFACE"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Section separators"
                description: "Draw divider lines between dashboard sections."
                checked: page.settings ? page.settings.dashboardSeparators : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.dashboardSeparators = !page.settings.dashboardSeparators;
                }
            }

            Text {
                Layout.fillWidth: true
                text: "The dashboard never grows past the configured max height; the notification list scrolls when it runs out of room."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 8
                wrapMode: Text.Wrap
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
                    onClicked: {
                        if (page.settings)
                            page.settings.resetDashboard();
                    }
                }
            }
        }
    }
}
