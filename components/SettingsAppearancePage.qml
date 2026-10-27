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
    readonly property string currentFont: settings ? settings.fontFamily : ""
    readonly property bool nerdFont: currentFont.length === 0
        || currentFont.toLowerCase().indexOf("nerd") !== -1
        || currentFont.toLowerCase().indexOf(" nf") !== -1
        || currentFont.toLowerCase().indexOf("symbols") !== -1

    signal fontSelectorRequested()

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

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 42
                radius: 8
                color: fontRowHover.hovered
                    ? Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.7)
                    : Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.4)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        Layout.preferredWidth: 92
                        text: "Font family"
                        color: page.mutedColor
                        font.family: page.monoFont
                        font.pixelSize: 8
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: page.currentFont
                        color: page.fgColor
                        font.family: page.monoFont
                        font.pixelSize: 9
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        Layout.preferredWidth: 58
                        Layout.preferredHeight: 24
                        radius: 6
                        color: Qt.rgba(page.accentColor.r, page.accentColor.g, page.accentColor.b, 0.16)

                        Text {
                            anchors.centerIn: parent
                            text: "CHANGE"
                            color: page.accentColor
                            font.family: page.monoFont
                            font.pixelSize: 7
                            font.weight: Font.Bold
                        }
                    }
                }

                HoverHandler {
                    id: fontRowHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: page.fontSelectorRequested()
                }
            }

            Text {
                Layout.fillWidth: true
                visible: !page.nerdFont
                text: "This family may not include Nerd Font icon glyphs."
                color: page.accentColor
                font.family: page.monoFont
                font.pixelSize: 8
                wrapMode: Text.Wrap
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
