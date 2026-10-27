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

    readonly property var expansionOptions: [
        { "key": "hover", "label": "Hover" },
        { "key": "click", "label": "Click" }
    ]

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
                text: "General"
                color: page.fgColor
                font.family: page.monoFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: "Island behavior and motion. Changes apply immediately."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 9
            }

            Text {
                text: "EXPAND ISLAND"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: page.expansionOptions

                    delegate: Rectangle {
                        id: expansionButton

                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        radius: 7
                        color: page.settings && page.settings.expansionMode === expansionButton.modelData.key
                            ? page.accentColor
                            : (expansionHover.hovered
                                ? Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.8)
                                : Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.4))

                        Text {
                            anchors.centerIn: parent
                            text: expansionButton.modelData.label
                            color: page.settings && page.settings.expansionMode === expansionButton.modelData.key
                                ? page.onAccentColor
                                : page.fgColor
                            font.family: page.monoFont
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }

                        HoverHandler {
                            id: expansionHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (page.settings)
                                    page.settings.expansionMode = expansionButton.modelData.key;
                            }
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: page.settings && page.settings.expansionMode === "click"
                    ? "Click the collapsed Island to pin it open. Hovering does not expand it."
                    : "Hover the Island to expand it; click to pin it open."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 8
                wrapMode: Text.Wrap
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Animation duration"
                value: page.settings ? page.settings.animationDuration : 220
                from: 80
                to: 600
                step: 10
                suffix: " ms"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.animationDuration = value;
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
                            page.settings.resetGeneral();
                    }
                }
            }
        }
    }
}
