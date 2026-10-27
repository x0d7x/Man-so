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
                text: "Appearance"
                color: page.fgColor
                font.family: page.monoFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: "Surface shape and contrast. Colors continue to come from Matugen."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 9
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Background opacity"
                value: page.settings ? page.settings.backgroundOpacity : 100
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
                        page.settings.backgroundOpacity = value;
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Corner radius"
                value: page.settings ? page.settings.cornerRadius : 17
                from: 8
                to: 32
                step: 1
                suffix: " px"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.cornerRadius = value;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Border"
                description: "Show the outline around the Island surface."
                checked: page.settings ? page.settings.borderVisible : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.borderVisible = !page.settings.borderVisible;
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Border thickness"
                value: page.settings ? page.settings.borderWidth : 1
                from: 1
                to: 4
                step: 1
                suffix: " px"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.borderWidth = value;
                }
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
                            page.settings.resetAppearance();
                    }
                }
            }
        }
    }
}
