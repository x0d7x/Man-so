import QtQuick
import QtQuick.Layouts

Rectangle {
    id: row

    property string label
    property string value
    property string monoFont
    property color fgColor
    property color mutedColor
    property color surfaceHighColor

    implicitHeight: 32
    radius: 8
    color: Qt.rgba(row.surfaceHighColor.r, row.surfaceHighColor.g, row.surfaceHighColor.b, 0.4)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8

        Text {
            Layout.preferredWidth: 92
            text: row.label
            color: row.mutedColor
            font.family: row.monoFont
            font.pixelSize: 8
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: row.value.length > 0 ? row.value : "—"
            color: row.fgColor
            font.family: row.monoFont
            font.pixelSize: 9
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }
}
