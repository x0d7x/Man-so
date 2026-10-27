import QtQuick
import QtQuick.Layouts

Item {
    id: page

    property var settings
    property var keyboardLayout
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
                text: "Keyboard"
                color: page.fgColor
                font.family: page.monoFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: "Switch between the keyboard layouts configured in MangoWM."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 9
                wrapMode: Text.Wrap
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 58
                radius: 8
                color: Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.4)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    Text {
                        text: "󰌌"
                        color: page.accentColor
                        font.family: page.monoFont
                        font.pixelSize: 20
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "CURRENT LAYOUT"
                            color: page.mutedColor
                            font.family: page.monoFont
                            font.pixelSize: 7
                            font.weight: Font.DemiBold
                            font.letterSpacing: 0.5
                        }

                        Text {
                            Layout.fillWidth: true
                            text: page.keyboardLayout ? page.keyboardLayout.currentLabel : "—"
                            color: page.fgColor
                            font.family: page.monoFont
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                    }

                    Text {
                        text: page.keyboardLayout ? page.keyboardLayout.positionText : ""
                        color: page.accentColor
                        font.family: page.monoFont
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }
                }
            }

            Text {
                text: "LAYOUTS"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            Text {
                Layout.fillWidth: true
                visible: page.keyboardLayout && page.keyboardLayout.layouts && page.keyboardLayout.layouts.length === 0
                text: "No keyboard layouts were found in MangoWM config."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 9
                wrapMode: Text.Wrap
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: page.keyboardLayout && page.keyboardLayout.layouts ? page.keyboardLayout.layouts : []

                    delegate: Rectangle {
                        id: layoutRow

                        required property var modelData
                        required property int index

                        readonly property bool active: page.keyboardLayout && page.keyboardLayout.currentIndex === layoutRow.index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        radius: 7
                        color: layoutRow.active
                            ? page.accentColor
                            : (layoutHover.hovered
                                ? Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.8)
                                : Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.4))

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 9
                            anchors.rightMargin: 9
                            spacing: 7

                            Text {
                                text: layoutRow.active ? "󰄬" : "󰌌"
                                color: layoutRow.active ? page.onAccentColor : page.accentColor
                                font.family: page.monoFont
                                font.pixelSize: 12
                            }

                            Text {
                                Layout.fillWidth: true
                                text: layoutRow.modelData.label
                                color: layoutRow.active ? page.onAccentColor : page.fgColor
                                font.family: page.monoFont
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            Text {
                                text: (layoutRow.modelData.variant || "").length > 0
                                    ? layoutRow.modelData.code + " / " + layoutRow.modelData.variant
                                    : layoutRow.modelData.code
                                color: layoutRow.active ? page.onAccentColor : page.mutedColor
                                font.family: page.monoFont
                                font.pixelSize: 8
                            }
                        }

                        HoverHandler {
                            id: layoutHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (page.keyboardLayout)
                                    page.keyboardLayout.switchTo(layoutRow.modelData);
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 108
                Layout.preferredHeight: 28
                radius: 7
                color: nextHover.hovered
                    ? Qt.rgba(page.accentColor.r, page.accentColor.g, page.accentColor.b, 0.2)
                    : Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.5)

                Text {
                    anchors.centerIn: parent
                    text: "NEXT LAYOUT"
                    color: nextHover.hovered ? page.accentColor : page.mutedColor
                    font.family: page.monoFont
                    font.pixelSize: 7
                    font.weight: Font.Bold
                }

                HoverHandler {
                    id: nextHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (page.keyboardLayout) page.keyboardLayout.switchNext()
                }
            }

            Text {
                text: "OSD"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Layout change OSD"
                description: "Show the current layout when MangoWM switches layouts."
                checked: page.settings ? page.settings.showKeyboardOsd : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showKeyboardOsd = !page.settings.showKeyboardOsd
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "OSD duration"
                value: page.settings ? page.settings.keyboardOsdTimeout : 1500
                from: 800
                to: 4000
                step: 100
                suffix: " ms"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.keyboardOsdTimeout = value;
                }
            }

            Text {
                Layout.fillWidth: true
                text: "Ctrl+Space is handled by MangoWM; changes made outside the Island also show the OSD."
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
                    onClicked: if (page.settings) page.settings.resetKeyboard()
                }
            }
        }
    }
}
