import QtQuick
import QtQuick.Layouts

// Logind session list shown inside the island. Opened with
// `qs -c maneso ipc call power sessions`; it is deliberately not part of the
// power menu.
FocusScope {
    id: panel

    property var sessions
    property string monoFont
    property real fontScale: 1
    property color fgColor
    property color mutedColor
    property color accentColor
    property color surfaceHighColor
    property color borderMutedColor

    signal closeRequested()

    focus: visible

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: {}
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "󰍹"
                color: panel.accentColor
                font.family: panel.monoFont
                font.pixelSize: Math.round(13 * panel.fontScale)
            }

            Text {
                Layout.fillWidth: true
                text: "Sessions"
                color: panel.fgColor
                font.family: panel.monoFont
                font.pixelSize: Math.round(12 * panel.fontScale)
                font.weight: Font.DemiBold
            }

            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 22
                radius: 6
                color: closeHover.hovered
                    ? Qt.rgba(panel.accentColor.r, panel.accentColor.g, panel.accentColor.b, 0.2)
                    : panel.surfaceHighColor

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    color: panel.mutedColor
                    font.family: panel.monoFont
                    font.pixelSize: Math.round(10 * panel.fontScale)
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

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: sessionColumn.implicitHeight

            ColumnLayout {
                id: sessionColumn
                width: parent.width
                spacing: 4

                Repeater {
                    model: panel.sessions ? panel.sessions.sessions : []

                    delegate: Rectangle {
                        id: sessionRow

                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        radius: 7
                        color: Qt.rgba(panel.surfaceHighColor.r, panel.surfaceHighColor.g, panel.surfaceHighColor.b, 0.45)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 9
                            anchors.rightMargin: 9
                            spacing: 8

                            Text {
                                Layout.preferredWidth: 44
                                text: sessionRow.modelData.id
                                color: panel.accentColor
                                font.family: panel.monoFont
                                font.pixelSize: Math.round(9 * panel.fontScale)
                                font.weight: Font.DemiBold
                            }

                            Text {
                                Layout.fillWidth: true
                                text: sessionRow.modelData.user
                                    + (sessionRow.modelData.tty.length > 0 ? "  ·  " + sessionRow.modelData.tty : "")
                                    + (sessionRow.modelData.seat.length > 0 ? "  ·  " + sessionRow.modelData.seat : "")
                                color: panel.fgColor
                                font.family: panel.monoFont
                                font.pixelSize: Math.round(9 * panel.fontScale)
                                elide: Text.ElideRight
                            }

                            Text {
                                text: sessionRow.modelData.class
                                color: panel.mutedColor
                                font.family: panel.monoFont
                                font.pixelSize: Math.round(8 * panel.fontScale)
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: panel.sessions !== null && panel.sessions !== undefined
                        && panel.sessions.sessions.length === 0
                    text: panel.sessions && panel.sessions.loading ? "Loading…" : "No sessions"
                    color: panel.mutedColor
                    font.family: panel.monoFont
                    font.pixelSize: Math.round(9 * panel.fontScale)
                }

                Text {
                    Layout.fillWidth: true
                    visible: panel.sessions && panel.sessions.lastError.length > 0
                    text: panel.sessions ? panel.sessions.lastError : ""
                    color: panel.accentColor
                    font.family: panel.monoFont
                    font.pixelSize: Math.round(8 * panel.fontScale)
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
