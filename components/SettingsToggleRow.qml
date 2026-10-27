import QtQuick
import QtQuick.Layouts

Rectangle {
    id: row

    property string label
    property string description
    property bool checked: false
    property string monoFont
    property color fgColor
    property color mutedColor
    property color accentColor
    property color onAccentColor
    property color surfaceHighColor

    signal toggled()

    implicitHeight: 44
    radius: 8
    color: Qt.rgba(row.surfaceHighColor.r, row.surfaceHighColor.g, row.surfaceHighColor.b, 0.4)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: row.label
                color: row.fgColor
                font.family: row.monoFont
                font.pixelSize: 10
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: row.description
                color: row.mutedColor
                font.family: row.monoFont
                font.pixelSize: 8
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 20
            radius: 10
            color: row.checked ? row.accentColor : row.surfaceHighColor

            Rectangle {
                width: 16
                height: 16
                radius: 8
                y: 2
                x: row.checked ? 18 : 2
                color: row.checked ? row.onAccentColor : row.fgColor

                Behavior on x {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: row.toggled()
            }
        }
    }
}
