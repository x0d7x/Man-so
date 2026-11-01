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
                text: "Notifications"
                color: page.fgColor
                font.family: page.monoFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: "History, the collapsed bell and the on-screen popup. Clicking the bell opens the dashboard."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 9
                wrapMode: Text.Wrap
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Enable notifications"
                description: "Show the OSD, history and notification center."
                checked: page.settings ? page.settings.showNotifications : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showNotifications = !page.settings.showNotifications
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Unread bell"
                description: "Show a bell in the collapsed Island when a new notification arrives."
                checked: page.settings ? page.settings.showUnreadBell : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showUnreadBell = !page.settings.showUnreadBell
            }

            Text {
                text: "DISPLAY & HISTORY"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Notification images"
                description: "Show image attachments in notification cards."
                checked: page.settings ? page.settings.showNotificationImages : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showNotificationImages = !page.settings.showNotificationImages
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Notification OSD duration"
                value: page.settings ? page.settings.notificationOsdTimeout : 6000
                from: 2200
                to: 12000
                step: 100
                suffix: " ms"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.notificationOsdTimeout = value;
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Notification history limit"
                value: page.settings ? page.settings.notificationHistoryLimit : 50
                from: 10
                to: 100
                step: 5
                suffix: ""
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.notificationHistoryLimit = value;
                }
            }


            Text {
                Layout.fillWidth: true
                text: "Clicking the bell in the collapsed Island opens the dashboard notification list; the separate popup stays available from the toggle IPC command."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 8
                wrapMode: Text.Wrap
            }

            Item { implicitHeight: 2 }

            Rectangle {
                Layout.preferredWidth: 150
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
                            page.settings.resetNotifications();
                    }
                }
            }
        }
    }
}
