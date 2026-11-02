import QtQuick
import QtQuick.Layouts

// Single-line text setting that commits on Enter or focus loss and reverts on Escape.
Rectangle {
    id: row

    property string label
    property string description
    property string value: ""
    property string placeholder: ""
    property int maximumLength: 255
    property bool clearAfterCommit: false
    property string monoFont
    property color fgColor
    property color mutedColor
    property color accentColor
    property color onAccentColor
    property color surfaceHighColor

    signal committed(string text)

    implicitHeight: row.description.length > 0 ? 58 : 40
    radius: 8
    color: Qt.rgba(row.surfaceHighColor.r, row.surfaceHighColor.g, row.surfaceHighColor.b, 0.4)

    function commit() {
        row.committed(input.text);
        if (row.clearAfterCommit) {
            input.text = row.value;
            input.focus = false;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.topMargin: 6
        anchors.bottomMargin: 6
        spacing: 3

        Text {
            text: row.label
            color: row.fgColor
            font.family: row.monoFont
            font.pixelSize: 10
            font.weight: Font.DemiBold
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 22
            radius: 6
            color: Qt.rgba(row.surfaceHighColor.r, row.surfaceHighColor.g, row.surfaceHighColor.b, 0.6)
            border.width: 1
            border.color: input.activeFocus ? row.accentColor : row.surfaceHighColor

            TextInput {
                id: input

                anchors.fill: parent
                anchors.leftMargin: 7
                anchors.rightMargin: 7
                verticalAlignment: TextInput.AlignVCenter
                text: row.value
                color: row.fgColor
                selectionColor: row.accentColor
                selectedTextColor: row.onAccentColor
                font.family: row.monoFont
                font.pixelSize: 9
                selectByMouse: true
                clip: true
                maximumLength: row.maximumLength
                onEditingFinished: row.commit()
                Keys.onReturnPressed: {
                    row.commit();
                    input.focus = false;
                }
                Keys.onEscapePressed: {
                    text = row.value;
                    input.focus = false;
                }
            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: 7
                verticalAlignment: Text.AlignVCenter
                visible: input.text.length === 0 && !input.activeFocus
                text: row.placeholder
                color: row.mutedColor
                font.family: row.monoFont
                font.pixelSize: 9
            }
        }

        Text {
            Layout.fillWidth: true
            visible: row.description.length > 0
            text: row.description
            color: row.mutedColor
            font.family: row.monoFont
            font.pixelSize: 8
            wrapMode: Text.Wrap
        }
    }

    Connections {
        target: row

        function onValueChanged() {
            if (!input.activeFocus)
                input.text = row.value;
        }
    }
}
