import QtQuick
import QtQuick.Layouts

Rectangle {
    id: row

    property string label
    property real value: 0
    property real from: 0
    property real to: 100
    property real step: 1
    property string suffix: ""
    property string monoFont
    property color fgColor
    property color mutedColor
    property color accentColor
    property color surfaceHighColor

    signal moved(real value)

    readonly property real ratio: row.to <= row.from
        ? 0
        : Math.max(0, Math.min(1, (row.value - row.from) / (row.to - row.from)))

    implicitHeight: 48
    radius: 8
    color: Qt.rgba(row.surfaceHighColor.r, row.surfaceHighColor.g, row.surfaceHighColor.b, 0.4)

    function commit(px) {
        if (track.width <= 0)
            return;
        const ratio = Math.max(0, Math.min(1, px / track.width));
        const raw = row.from + (row.to - row.from) * ratio;
        const stepped = row.from + Math.round((raw - row.from) / row.step) * row.step;
        row.moved(Math.max(row.from, Math.min(row.to, stepped)));
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.topMargin: 6
        anchors.bottomMargin: 6
        spacing: 3

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

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
                text: Math.round(row.value) + row.suffix
                color: row.accentColor
                font.family: row.monoFont
                font.pixelSize: 9
                font.weight: Font.DemiBold
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 10

            Rectangle {
                id: track

                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 4
                radius: 2
                color: row.surfaceHighColor

                Rectangle {
                    width: parent.width * row.ratio
                    height: parent.height
                    radius: parent.radius
                    color: row.accentColor
                }
            }

            Rectangle {
                width: 10
                height: 10
                radius: 5
                x: Math.max(0, Math.min(track.width - width, track.width * row.ratio - width / 2))
                anchors.verticalCenter: parent.verticalCenter
                color: row.accentColor
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse => row.commit(mouse.x)
                onPositionChanged: mouse => {
                    if (pressed)
                        row.commit(mouse.x);
                }
            }
        }
    }
}
