import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var notifications
    property string monoFont
    property real fontScale: 1
    property bool showImages: true
    property color surfaceHighColor
    property color fgColor
    property color mutedColor
    property color errorColor
    property color borderColor
    property color borderMutedColor

    ListView {
        anchors.fill: parent
        clip: true
        spacing: 4
        model: root.notifications ? root.notifications.groups : []

        delegate: Column {
            id: notificationGroup

            required property var modelData

            readonly property var group: modelData

            width: ListView.view.width
            spacing: 3

            Rectangle {
                id: groupHeader

                width: parent.width
                height: 66
                radius: 8
                color: groupHover.hovered ? root.surfaceHighColor : "transparent"

                HoverHandler {
                    id: groupHover
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: 8
                        color: root.surfaceHighColor
                        clip: true

                        Image {
                            id: groupImage
                            anchors.fill: parent
                            source: notificationGroup.group.items.length > 0
                                ? notificationGroup.group.items[0].image
                                : ""
                            sourceSize.width: 36
                            sourceSize.height: 36
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            visible: notificationGroup.group.items.length > 0
                                && notificationGroup.group.items[0].image.length > 0
                                && status === Image.Ready
                        }

                        IconImage {
                            id: groupIcon
                            anchors.centerIn: parent
                            visible: !groupImage.visible
                            source: root.notifications
                                ? root.notifications.resolveIcon(notificationGroup.group.appIcon)
                                : ""
                            implicitSize: 22
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !groupImage.visible && groupIcon.status !== Image.Ready
                            text: "󰂚"
                            color: root.mutedColor
                            font.family: root.monoFont
                            font.pixelSize: Math.round(17 * root.fontScale)
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                Layout.fillWidth: true
                                text: notificationGroup.group.appName
                                color: root.mutedColor
                                font.family: root.monoFont
                                font.pixelSize: Math.round(9 * root.fontScale)
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            Text {
                                visible: notificationGroup.group.count > 1
                                text: "×" + notificationGroup.group.count
                                color: root.borderColor
                                font.family: root.monoFont
                                font.pixelSize: Math.round(8 * root.fontScale)
                                font.weight: Font.DemiBold
                            }

                            Rectangle {
                                visible: notificationGroup.group.items.length > 0
                                    && notificationGroup.group.items[0].urgency === NotificationUrgency.Critical
                                width: 5
                                height: 5
                                radius: 3
                                color: root.errorColor
                            }

                            Text {
                                text: notificationGroup.group.items.length > 0
                                    ? Qt.formatTime(new Date(notificationGroup.group.items[0].timestamp), "hh:mm")
                                    : ""
                                color: root.borderColor
                                font.family: root.monoFont
                                font.pixelSize: Math.round(8 * root.fontScale)
                            }

                            Text {
                                text: notificationGroup.group.expanded ? "▾" : "▸"
                                color: root.mutedColor
                                font.family: root.monoFont
                                font.pixelSize: Math.round(10 * root.fontScale)
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: notificationGroup.group.items.length > 0
                                ? notificationGroup.group.items[0].summary
                                : ""
                            color: root.fgColor
                            font.family: root.monoFont
                            font.pixelSize: Math.round(10 * root.fontScale)
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            textFormat: Text.PlainText
                        }

                        Text {
                            Layout.fillWidth: true
                            text: notificationGroup.group.items.length > 0
                                ? notificationGroup.group.items[0].body
                                : ""
                            color: root.mutedColor
                            font.family: root.monoFont
                            font.pixelSize: Math.round(8 * root.fontScale)
                            wrapMode: Text.Wrap
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            textFormat: Text.PlainText
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.notifications)
                            root.notifications.toggleGroup(notificationGroup.group.key);
                    }
                }
            }

            Repeater {
                model: notificationGroup.group.expanded ? notificationGroup.group.items : []

                delegate: Rectangle {
                    id: messageRow

                    required property var modelData

                    width: notificationGroup.width
                    height: 62
                    radius: 7
                    color: messageHover.hovered ? root.surfaceHighColor : "transparent"

                    HoverHandler {
                        id: messageHover
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 6
                        anchors.topMargin: 5
                        anchors.bottomMargin: 5
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 2
                            Layout.fillHeight: true
                            Layout.topMargin: 4
                            Layout.bottomMargin: 4
                            radius: 1
                            color: root.borderMutedColor
                            opacity: 0.6
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 5

                                Text {
                                    Layout.fillWidth: true
                                    text: messageRow.modelData.summary.length > 0
                                        ? messageRow.modelData.summary
                                        : messageRow.modelData.appName
                                    color: root.fgColor
                                    font.family: root.monoFont
                                    font.pixelSize: Math.round(9 * root.fontScale)
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    textFormat: Text.PlainText
                                }

                                Text {
                                    text: Qt.formatTime(new Date(messageRow.modelData.timestamp), "hh:mm")
                                    color: root.borderColor
                                    font.family: root.monoFont
                                    font.pixelSize: Math.round(7 * root.fontScale)
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: messageRow.modelData.body
                                color: root.mutedColor
                                font.family: root.monoFont
                                font.pixelSize: Math.round(8 * root.fontScale)
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                maximumLineCount: 3
                                textFormat: Text.PlainText
                            }
                        }
                    }
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: !root.notifications || root.notifications.history.length === 0
        text: "No notifications"
        color: root.mutedColor
        font.family: root.monoFont
        font.pixelSize: Math.round(10 * root.fontScale)
    }
}
