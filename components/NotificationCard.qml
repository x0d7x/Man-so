import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card

    property var notifications
    property string monoFont
    property real fontScale: 1
    property color bgColor
    property color surfaceHighColor
    property color fgColor
    property color mutedColor
    property color accentColor
    property color onAccentColor
    property color errorColor
    property color borderMutedColor

    readonly property var note: card.notifications ? card.notifications.active : null

    radius: 16
    color: Qt.rgba(card.bgColor.r, card.bgColor.g, card.bgColor.b, 0.98)
    border.width: 1
    border.color: card.notifications && card.notifications.activeCritical
        ? card.errorColor
        : (card.notifications && card.notifications.activeLow ? card.borderMutedColor : card.accentColor)
    clip: true

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: {
            if (card.notifications)
                card.notifications.invokeDefault();
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            Layout.alignment: Qt.AlignVCenter
            radius: 12
            color: card.surfaceHighColor
            clip: true

            Image {
                id: notificationImage
                anchors.fill: parent
                source: card.notifications ? card.notifications.activeImage : ""
                sourceSize.width: 64
                sourceSize.height: 64
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                visible: card.notifications && card.notifications.activeImage.length > 0
                    && status === Image.Ready
            }

            IconImage {
                id: notificationIcon
                anchors.centerIn: parent
                visible: !notificationImage.visible
                source: card.notifications
                    ? card.notifications.resolveIcon(card.note ? card.note.appIcon : "")
                    : ""
                implicitSize: 36
            }

            Text {
                anchors.centerIn: parent
                visible: !notificationImage.visible && notificationIcon.status !== Image.Ready
                text: "󰂚"
                color: card.mutedColor
                font.family: card.monoFont
                font.pixelSize: Math.round(28 * card.fontScale)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    text: card.note ? card.note.appName : ""
                    color: card.mutedColor
                    font.family: card.monoFont
                    font.pixelSize: Math.round(9 * card.fontScale)
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Rectangle {
                    visible: card.notifications && card.notifications.activeCritical
                    width: 6
                    height: 6
                    radius: 3
                    color: card.errorColor
                }

                Item {
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        color: card.mutedColor
                        font.family: card.monoFont
                        font.pixelSize: Math.round(13 * card.fontScale)
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (card.notifications)
                                card.notifications.dismissActive();
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: card.note ? card.note.summary : ""
                color: card.fgColor
                font.family: card.monoFont
                font.pixelSize: Math.round(12 * card.fontScale)
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                maximumLineCount: 1
                textFormat: Text.PlainText
            }

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: card.note ? card.note.body : ""
                color: card.note && card.note.body.length > 0 ? card.mutedColor : "transparent"
                font.family: card.monoFont
                font.pixelSize: Math.round(9 * card.fontScale)
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 2
                textFormat: Text.PlainText
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: card.notifications && card.notifications.activeActions.length > 0

                Repeater {
                    model: card.notifications ? card.notifications.activeActions.slice(0, 2) : []

                    delegate: Rectangle {
                        id: notificationAction

                        required property var modelData

                        Layout.preferredWidth: actionText.implicitWidth + 18
                        Layout.preferredHeight: 22
                        radius: 6
                        color: notificationActionHover.hovered
                            ? card.accentColor
                            : card.surfaceHighColor

                        Text {
                            id: actionText
                            anchors.centerIn: parent
                            text: notificationAction.modelData.text
                            color: notificationActionHover.hovered
                                ? card.onAccentColor
                                : card.fgColor
                            font.family: card.monoFont
                            font.pixelSize: Math.round(9 * card.fontScale)
                            font.weight: Font.DemiBold
                        }

                        HoverHandler {
                            id: notificationActionHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (card.notifications)
                                    card.notifications.invokeAction(notificationAction.modelData);
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
