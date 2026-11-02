import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card

    property var notifications
    property bool showImages: true
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
    readonly property bool critical: card.notifications && card.notifications.activeCritical
    readonly property bool low: card.notifications && card.notifications.activeLow
    readonly property color urgencyColor: card.critical
        ? card.errorColor
        : (card.low ? card.borderMutedColor : card.accentColor)
    readonly property int dismissTimeout: card.notifications ? card.notifications.activeTimeout : 0
    readonly property bool progressVisible: card.dismissTimeout > 0 && card.note !== null
    property real timeoutProgress: 1

    radius: 18
    clip: true
    color: card.bgColor
    border.width: 1
    border.color: card.critical
        ? Qt.rgba(card.errorColor.r, card.errorColor.g, card.errorColor.b, 0.75)
        : (card.low
            ? Qt.rgba(card.borderMutedColor.r, card.borderMutedColor.g, card.borderMutedColor.b, 0.55)
            : Qt.rgba(card.accentColor.r, card.accentColor.g, card.accentColor.b, 0.45))

    NumberAnimation {
        id: timeoutAnim

        target: card
        property: "timeoutProgress"
        from: 1
        to: 0
        duration: Math.max(1, card.dismissTimeout)
        easing.type: Easing.Linear
    }

    Connections {
        target: card.notifications

        function onActiveChanged() {
            Qt.callLater(() => {
                card.timeoutProgress = 1;
                timeoutAnim.stop();
                if (card.dismissTimeout > 0) {
                    timeoutAnim.duration = card.dismissTimeout;
                    timeoutAnim.start();
                }
            });
        }
    }

    Component.onCompleted: {
        if (card.dismissTimeout > 0) {
            timeoutAnim.duration = card.dismissTimeout;
            timeoutAnim.start();
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 1
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        height: 1
        radius: 1
        color: Qt.rgba(1, 1, 1, 0.06)
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 14
        anchors.bottomMargin: 14
        width: 3
        radius: 1.5
        color: card.urgencyColor
        opacity: card.low ? 0.7 : 0.95
    }

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
        anchors.leftMargin: 14
        anchors.rightMargin: 12
        anchors.topMargin: 12
        anchors.bottomMargin: 14
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 54
            Layout.preferredHeight: 54
            Layout.alignment: Qt.AlignTop
            radius: 15
            clip: true
            color: Qt.rgba(card.urgencyColor.r, card.urgencyColor.g, card.urgencyColor.b, 0.13)
            border.width: 1
            border.color: Qt.rgba(card.urgencyColor.r, card.urgencyColor.g, card.urgencyColor.b, 0.3)

            Image {
                id: notificationImage
                anchors.fill: parent
                source: card.notifications ? card.notifications.activeImage : ""
                sourceSize.width: 54
                sourceSize.height: 54
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                // Transient: keep decoded copies out of Qt's pixmap cache.
                cache: false
                visible: card.showImages && source.toString().length > 0
                    && status === Image.Ready
            }

            IconImage {
                id: notificationIcon
                anchors.centerIn: parent
                visible: !notificationImage.visible
                source: card.notifications
                    ? card.notifications.resolveIcon(card.note ? card.note.appIcon : "")
                    : ""
                implicitSize: 26
            }

            Text {
                anchors.centerIn: parent
                visible: !notificationImage.visible && notificationIcon.status !== Image.Ready
                text: "󰂚"
                color: card.urgencyColor
                font.family: card.monoFont
                font.pixelSize: Math.round(22 * card.fontScale)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 3

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
                    font.letterSpacing: 0.3
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Rectangle {
                    visible: card.critical
                    Layout.preferredWidth: criticalLabel.implicitWidth + 10
                    Layout.preferredHeight: 15
                    radius: 7.5
                    color: Qt.rgba(card.errorColor.r, card.errorColor.g, card.errorColor.b, 0.18)

                    Text {
                        id: criticalLabel
                        anchors.centerIn: parent
                        text: "CRITICAL"
                        color: card.errorColor
                        font.family: card.monoFont
                        font.pixelSize: Math.round(6.5 * card.fontScale)
                        font.weight: Font.Bold
                        font.letterSpacing: 0.4
                    }
                }

                Item {
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22

                    Rectangle {
                        anchors.fill: parent
                        radius: 7
                        color: dismissHover.hovered
                            ? Qt.rgba(card.surfaceHighColor.r, card.surfaceHighColor.g, card.surfaceHighColor.b, 0.8)
                            : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: card.mutedColor
                            font.family: card.monoFont
                            font.pixelSize: Math.round(11 * card.fontScale)
                        }
                    }

                    HoverHandler {
                        id: dismissHover
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
                visible: text.length > 0
                text: card.note ? card.note.body : ""
                color: card.mutedColor
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

                        Layout.preferredWidth: actionText.implicitWidth + 20
                        Layout.preferredHeight: 22
                        radius: 7
                        color: notificationActionHover.hovered
                            ? card.accentColor
                            : Qt.rgba(card.surfaceHighColor.r, card.surfaceHighColor.g, card.surfaceHighColor.b, 0.6)
                        border.width: 1
                        border.color: notificationActionHover.hovered
                            ? "transparent"
                            : Qt.rgba(card.borderMutedColor.r, card.borderMutedColor.g, card.borderMutedColor.b, 0.5)

                        Text {
                            id: actionText
                            anchors.centerIn: parent
                            text: notificationAction.modelData.text
                            color: notificationActionHover.hovered
                                ? card.onAccentColor
                                : card.fgColor
                            font.family: card.monoFont
                            font.pixelSize: Math.round(8.5 * card.fontScale)
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

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 2
        visible: card.progressVisible
        color: Qt.rgba(card.urgencyColor.r, card.urgencyColor.g, card.urgencyColor.b, 0.16)

        Rectangle {
            width: parent.width * card.timeoutProgress
            height: parent.height
            radius: 1
            color: card.urgencyColor
        }
    }
}
