import QtQuick
import QtQuick.Layouts

// Labelled segmented choice. Options are [{ "key": "...", "label": "..." }].
Rectangle {
    id: row

    property string label
    property var options: []
    property string value: ""
    property string monoFont
    property color fgColor
    property color mutedColor
    property color accentColor
    property color onAccentColor
    property color surfaceHighColor

    signal selected(string key)

    implicitHeight: 44
    radius: 8
    color: Qt.rgba(row.surfaceHighColor.r, row.surfaceHighColor.g, row.surfaceHighColor.b, 0.4)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8

        Text {
            text: row.label
            color: row.fgColor
            font.family: row.monoFont
            font.pixelSize: 10
            font.weight: Font.DemiBold
        }

        Item { Layout.fillWidth: true }

        Repeater {
            model: row.options

            delegate: Rectangle {
                id: optionButton

                required property var modelData

                Layout.preferredHeight: 26
                Layout.preferredWidth: Math.max(44, optionLabel.implicitWidth + 18)
                radius: 7
                color: row.value === optionButton.modelData.key
                    ? row.accentColor
                    : (optionHover.hovered
                        ? Qt.rgba(row.surfaceHighColor.r, row.surfaceHighColor.g, row.surfaceHighColor.b, 0.9)
                        : Qt.rgba(row.surfaceHighColor.r, row.surfaceHighColor.g, row.surfaceHighColor.b, 0.5))

                Text {
                    id: optionLabel
                    anchors.centerIn: parent
                    text: optionButton.modelData.label
                    color: row.value === optionButton.modelData.key ? row.onAccentColor : row.mutedColor
                    font.family: row.monoFont
                    font.pixelSize: 8
                    font.weight: Font.DemiBold
                }

                HoverHandler {
                    id: optionHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: row.selected(optionButton.modelData.key)
                }
            }
        }
    }
}
