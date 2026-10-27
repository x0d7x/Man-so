import QtQuick
import QtQuick.Layouts

FocusScope {
    id: panel

    signal closeRequested()

    property string monoFont
    property color surfaceHighColor
    property color fgColor
    property color mutedColor
    property color accentColor
    property color onAccentColor
    property color borderMutedColor

    anchors.fill: parent
    focus: visible

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: {}
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            spacing: 8

            Item {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: backHover.hovered
                        ? Qt.rgba(panel.surfaceHighColor.r, panel.surfaceHighColor.g, panel.surfaceHighColor.b, 0.9)
                        : Qt.rgba(panel.surfaceHighColor.r, panel.surfaceHighColor.g, panel.surfaceHighColor.b, 0.5)
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰁍"
                    color: panel.fgColor
                    font.family: panel.monoFont
                    font.pixelSize: 15
                }

                HoverHandler {
                    id: backHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: panel.closeRequested()
                }
            }

            Text {
                text: "SETTINGS"
                color: panel.accentColor
                font.family: panel.monoFont
                font.pixelSize: 11
                font.weight: Font.Bold
                font.letterSpacing: 0.6
            }

            Item {
                Layout.fillWidth: true
            }

            Item {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: closeHover.hovered
                        ? Qt.rgba(panel.surfaceHighColor.r, panel.surfaceHighColor.g, panel.surfaceHighColor.b, 0.9)
                        : Qt.rgba(panel.surfaceHighColor.r, panel.surfaceHighColor.g, panel.surfaceHighColor.b, 0.5)
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    color: panel.mutedColor
                    font.family: panel.monoFont
                    font.pixelSize: 13
                }

                HoverHandler {
                    id: closeHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: panel.closeRequested()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: panel.borderMutedColor
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: Qt.rgba(panel.surfaceHighColor.r, panel.surfaceHighColor.g, panel.surfaceHighColor.b, 0.32)
            border.width: 1
            border.color: Qt.rgba(panel.borderMutedColor.r, panel.borderMutedColor.g, panel.borderMutedColor.b, 0.35)

            Column {
                anchors.centerIn: parent
                spacing: 9

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰒓"
                    color: panel.accentColor
                    font.family: panel.monoFont
                    font.pixelSize: 34
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Settings Center"
                    color: panel.fgColor
                    font.family: panel.monoFont
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Section navigation and configuration will be added next."
                    color: panel.mutedColor
                    font.family: panel.monoFont
                    font.pixelSize: 9
                }
            }
        }
    }

    Shortcut {
        sequence: "Esc"
        enabled: panel.visible
        onActivated: panel.closeRequested()
    }

    Timer {
        interval: 100
        running: panel.visible
        repeat: false
        onTriggered: panel.forceActiveFocus()
    }

    Keys.onEscapePressed: panel.closeRequested()

    onVisibleChanged: {
        if (panel.visible)
            Qt.callLater(() => panel.forceActiveFocus());
    }
}
