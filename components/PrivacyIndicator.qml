import QtQuick

Row {
    id: root

    property var host

    readonly property bool microphoneActive: root.host && root.host.privacy && root.host.privacy.microphoneActive
    readonly property bool screenActive: root.host && root.host.privacy && root.host.privacy.screenActive
    readonly property int microphoneSessions: root.host && root.host.privacy ? root.host.privacy.microphoneSessionCount : 0
    readonly property int screenSessions: root.host && root.host.privacy ? root.host.privacy.screenSessionCount : 0

    visible: (root.microphoneActive || root.screenActive)
        && root.host && root.host.privacyShowCollapsed
    spacing: 5

    Row {
        visible: root.microphoneActive
        spacing: 2

        Text {
            text: "󰍬"
            color: root.host ? root.host.errorColor : "transparent"
            font.family: root.host ? root.host.monoFont : ""
            font.pixelSize: root.host ? Math.round(12 * root.host.fontScale) : 12
            font.weight: Font.Medium
        }

        Text {
            visible: root.microphoneSessions > 1
            anchors.verticalCenter: parent.verticalCenter
            text: "×" + root.microphoneSessions
            color: root.host ? root.host.mutedColor : "transparent"
            font.family: root.host ? root.host.monoFont : ""
            font.pixelSize: root.host ? Math.round(8 * root.host.fontScale) : 8
            font.weight: Font.DemiBold
        }
    }

    Row {
        visible: root.screenActive
        spacing: 2

        Text {
            text: "󰍹"
            color: root.host ? root.host.errorColor : "transparent"
            font.family: root.host ? root.host.monoFont : ""
            font.pixelSize: root.host ? Math.round(12 * root.host.fontScale) : 12
            font.weight: Font.Medium
        }

        Text {
            visible: root.screenSessions > 1
            anchors.verticalCenter: parent.verticalCenter
            text: "×" + root.screenSessions
            color: root.host ? root.host.mutedColor : "transparent"
            font.family: root.host ? root.host.monoFont : ""
            font.pixelSize: root.host ? Math.round(8 * root.host.fontScale) : 8
            font.weight: Font.DemiBold
        }
    }
}
