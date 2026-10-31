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
    property color accentColor
    property color surfaceHighColor
    property color fgColor
    property color mutedColor
    property color errorColor
    property color borderColor
    property color borderMutedColor

    readonly property var groups: root.notifications ? root.notifications.groups : []
    readonly property double nowTick: ticker.now

    function itemAt(group, index) {
        if (!group || !group.items || group.items.length <= index)
            return null;
        return group.items[index];
    }

    function groupAccent(group) {
        const note = root.itemAt(group, 0);
        if (!note)
            return root.borderMutedColor;
        if (note.urgency === NotificationUrgency.Critical)
            return root.errorColor;
        if (note.urgency === NotificationUrgency.Low)
            return root.borderMutedColor;
        return root.accentColor;
    }

    function groupCritical(group) {
        const note = root.itemAt(group, 0);
        return note && note.urgency === NotificationUrgency.Critical;
    }

    function relativeTime(timestamp) {
        return root.notifications
            ? root.notifications.relativeTime(timestamp, root.nowTick)
            : "";
    }

    Timer {
        id: ticker

        property double now: Date.now()

        interval: 30000
        running: true
        repeat: true
        onTriggered: now = Date.now()
    }

    ListView {
        id: list

        anchors.fill: parent
        rightMargin: 9
        clip: true
        spacing: 8
        cacheBuffer: 400
        boundsBehavior: Flickable.StopAtBounds
        model: root.groups

        delegate: Column {
            id: groupColumn

            required property var modelData

            readonly property var group: modelData
            readonly property color groupAccent: root.groupAccent(groupColumn.group)

            width: ListView.view.width
            spacing: 5

            Rectangle {
                id: groupCard

                width: parent.width
                height: Math.max(78, groupContent.implicitHeight + 24)
                radius: 12
                clip: true
                color: groupHover.hovered
                    ? Qt.rgba(root.surfaceHighColor.r, root.surfaceHighColor.g, root.surfaceHighColor.b, 0.85)
                    : Qt.rgba(root.surfaceHighColor.r, root.surfaceHighColor.g, root.surfaceHighColor.b, 0.42)
                border.width: 1
                border.color: groupHover.hovered
                    ? Qt.rgba(groupColumn.groupAccent.r, groupColumn.groupAccent.g, groupColumn.groupAccent.b, 0.55)
                    : Qt.rgba(groupColumn.groupAccent.r, groupColumn.groupAccent.g, groupColumn.groupAccent.b, 0.22)

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                HoverHandler {
                    id: groupHover
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 12
                    anchors.bottomMargin: 12
                    width: 3
                    radius: 1.5
                    color: groupColumn.groupAccent
                    opacity: 0.9
                }

                RowLayout {
                    id: groupContent

                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 12
                    anchors.topMargin: 12
                    anchors.bottomMargin: 12
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 42
                        Layout.alignment: Qt.AlignTop
                        radius: 12
                        clip: true
                        color: Qt.rgba(groupColumn.groupAccent.r, groupColumn.groupAccent.g, groupColumn.groupAccent.b, 0.14)
                        border.width: 1
                        border.color: Qt.rgba(groupColumn.groupAccent.r, groupColumn.groupAccent.g, groupColumn.groupAccent.b, 0.28)

                        Image {
                            id: groupImage
                            anchors.fill: parent
                            source: {
                                const note = root.itemAt(groupColumn.group, 0);
                                return note ? note.image : "";
                            }
                            sourceSize.width: 42
                            sourceSize.height: 42
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            visible: root.showImages && source.toString().length > 0
                                && status === Image.Ready
                        }

                        IconImage {
                            id: groupIcon
                            anchors.centerIn: parent
                            visible: !groupImage.visible
                            source: root.notifications
                                ? root.notifications.resolveIcon(groupColumn.group.appIcon)
                                : ""
                            implicitSize: 22
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !groupImage.visible && groupIcon.status !== Image.Ready
                            text: "󰂚"
                            color: groupColumn.groupAccent
                            font.family: root.monoFont
                            font.pixelSize: Math.round(17 * root.fontScale)
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                Layout.fillWidth: true
                                text: groupColumn.group.appName
                                color: root.mutedColor
                                font.family: root.monoFont
                                font.pixelSize: Math.round(9 * root.fontScale)
                                font.weight: Font.DemiBold
                                font.letterSpacing: 0.3
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            Rectangle {
                                visible: groupColumn.group.count > 1
                                Layout.preferredWidth: countLabel.implicitWidth + 10
                                Layout.preferredHeight: 15
                                radius: 7.5
                                color: Qt.rgba(groupColumn.groupAccent.r, groupColumn.groupAccent.g, groupColumn.groupAccent.b, 0.18)

                                Text {
                                    id: countLabel
                                    anchors.centerIn: parent
                                    text: groupColumn.group.count
                                    color: groupColumn.groupAccent
                                    font.family: root.monoFont
                                    font.pixelSize: Math.round(7 * root.fontScale)
                                    font.weight: Font.Bold
                                }
                            }

                            Rectangle {
                                visible: root.groupCritical(groupColumn.group)
                                Layout.preferredWidth: criticalLabel.implicitWidth + 10
                                Layout.preferredHeight: 15
                                radius: 7.5
                                color: Qt.rgba(root.errorColor.r, root.errorColor.g, root.errorColor.b, 0.18)

                                Text {
                                    id: criticalLabel
                                    anchors.centerIn: parent
                                    text: "CRITICAL"
                                    color: root.errorColor
                                    font.family: root.monoFont
                                    font.pixelSize: Math.round(6.5 * root.fontScale)
                                    font.weight: Font.Bold
                                    font.letterSpacing: 0.4
                                }
                            }

                            Text {
                                text: {
                                    const note = root.itemAt(groupColumn.group, 0);
                                    return note ? root.relativeTime(note.timestamp) : "";
                                }
                                color: root.borderColor
                                font.family: root.monoFont
                                font.pixelSize: Math.round(8 * root.fontScale)
                            }

                            Rectangle {
                                Layout.preferredWidth: 18
                                Layout.preferredHeight: 18
                                radius: 6
                                color: Qt.rgba(root.surfaceHighColor.r, root.surfaceHighColor.g, root.surfaceHighColor.b, groupHover.hovered ? 0.9 : 0.0)

                                Text {
                                    anchors.centerIn: parent
                                    text: groupColumn.group.expanded ? "󰅃" : "󰅀"
                                    color: root.mutedColor
                                    font.family: root.monoFont
                                    font.pixelSize: Math.round(9 * root.fontScale)
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: {
                                const note = root.itemAt(groupColumn.group, 0);
                                if (!note)
                                    return "";
                                return note.summary.length > 0 ? note.summary : note.appName;
                            }
                            color: root.fgColor
                            font.family: root.monoFont
                            font.pixelSize: Math.round(10.5 * root.fontScale)
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            textFormat: Text.PlainText
                        }

                        Text {
                            Layout.fillWidth: true
                            text: {
                                const note = root.itemAt(groupColumn.group, 0);
                                return note ? note.body : "";
                            }
                            color: root.mutedColor
                            font.family: root.monoFont
                            font.pixelSize: Math.round(8.5 * root.fontScale)
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
                            root.notifications.toggleGroup(groupColumn.group.key);
                    }
                }
            }

            Repeater {
                model: groupColumn.group.expanded ? groupColumn.group.items : []

                delegate: Rectangle {
                    id: messageRow

                    required property var modelData

                    x: 18
                    width: groupColumn.width - 18
                    height: Math.max(52, messageContent.implicitHeight + 16)
                    radius: 10
                    color: messageHover.hovered
                        ? Qt.rgba(root.surfaceHighColor.r, root.surfaceHighColor.g, root.surfaceHighColor.b, 0.6)
                        : Qt.rgba(root.surfaceHighColor.r, root.surfaceHighColor.g, root.surfaceHighColor.b, 0.3)
                    border.width: 1
                    border.color: Qt.rgba(root.borderMutedColor.r, root.borderMutedColor.g, root.borderMutedColor.b, messageHover.hovered ? 0.6 : 0.3)

                    HoverHandler {
                        id: messageHover
                    }

                    RowLayout {
                        id: messageContent

                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 2
                            Layout.fillHeight: true
                            Layout.topMargin: 3
                            Layout.bottomMargin: 3
                            radius: 1
                            color: groupColumn.groupAccent
                            opacity: 0.6
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

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
                                    text: root.relativeTime(messageRow.modelData.timestamp)
                                    color: root.borderColor
                                    font.family: root.monoFont
                                    font.pixelSize: Math.round(7.5 * root.fontScale)
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

    Rectangle {
        id: scrollbar

        readonly property bool needed: list.contentHeight > list.height + 1

        visible: needed
        x: list.width - 5
        y: needed
            ? list.contentY / Math.max(1, list.contentHeight - list.height) * (list.height - height)
            : 0
        width: 3
        height: needed ? Math.max(22, list.height / list.contentHeight * list.height) : 0
        radius: 1.5
        color: Qt.rgba(root.borderColor.r, root.borderColor.g, root.borderColor.b, 0.55)
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 7
        visible: root.groups.length === 0

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 54
            Layout.preferredHeight: 54
            radius: 17
            color: Qt.rgba(root.surfaceHighColor.r, root.surfaceHighColor.g, root.surfaceHighColor.b, 0.45)
            border.width: 1
            border.color: Qt.rgba(root.borderMutedColor.r, root.borderMutedColor.g, root.borderMutedColor.b, 0.4)

            Text {
                anchors.centerIn: parent
                text: "󰂛"
                color: root.mutedColor
                font.family: root.monoFont
                font.pixelSize: Math.round(23 * root.fontScale)
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "All caught up"
            color: root.fgColor
            font.family: root.monoFont
            font.pixelSize: Math.round(11 * root.fontScale)
            font.weight: Font.DemiBold
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "New notifications will show up here."
            color: root.mutedColor
            font.family: root.monoFont
            font.pixelSize: Math.round(8.5 * root.fontScale)
        }
    }
}
