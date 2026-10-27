import QtQuick
import QtQuick.Layouts

Item {
    id: page

    property var settings
    property var privacy
    property string monoFont
    property color fgColor
    property color mutedColor
    property color accentColor
    property color onAccentColor
    property color surfaceHighColor
    property color errorColor

    readonly property bool monitoringEnabled: page.settings ? page.settings.privacyEnabled : true
    readonly property bool microphoneEnabled: page.settings ? page.settings.privacyMicrophoneEnabled : true
    readonly property bool known: page.privacy ? page.privacy.microphoneKnown : false
    readonly property bool active: page.privacy ? page.privacy.microphoneActive : false
    readonly property bool screenEnabled: page.settings ? page.settings.privacyScreenEnabled : true
    readonly property bool screenKnown: page.privacy ? page.privacy.screenKnown : false
    readonly property bool screenActive: page.privacy ? page.privacy.screenActive : false
    readonly property string statusText: {
        if (!page.monitoringEnabled)
            return "Monitoring disabled";
        if (!page.microphoneEnabled)
            return "Microphone monitoring disabled";
        if (!page.known)
            return "State unavailable";
        return page.active ? "Microphone active" : "No microphone capture";
    }
    readonly property string appText: {
        if (!page.active)
            return "";
        const apps = page.privacy ? page.privacy.microphoneApps : [];
        if (!apps || apps.length === 0)
            return "Unknown application";
        const count = page.privacy ? page.privacy.microphoneSessionCount : 0;
        return apps.join(", ") + (count > 1 ? " · " + count + " streams" : "");
    }
    readonly property string screenStatusText: {
        if (!page.monitoringEnabled)
            return "Monitoring disabled";
        if (!page.screenEnabled)
            return "Screen monitoring disabled";
        if (!page.screenKnown)
            return "Screen state unavailable";
        return page.screenActive ? "Screen capture active" : "No screen capture";
    }
    readonly property string screenAppText: {
        if (!page.screenActive)
            return "";
        const apps = page.privacy ? page.privacy.screenApps : [];
        if (!apps || apps.length === 0)
            return "Unknown application";
        const count = page.privacy ? page.privacy.screenSessionCount : 0;
        return apps.join(", ") + (count > 1 ? " · " + count + " streams" : "");
    }

    Flickable {
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: content.implicitHeight

        ColumnLayout {
            id: content
            width: parent.width
            spacing: 8

            Text {
                text: "Privacy"
                color: page.fgColor
                font.family: page.monoFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: "Indicators for sensitive activity reported by PipeWire. No audio, camera images, or screen contents are captured."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 9
                wrapMode: Text.Wrap
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 62
                radius: 8
                color: Qt.rgba(page.errorColor.r, page.errorColor.g, page.errorColor.b, page.active ? 0.14 : 0.04)
                border.width: 1
                border.color: page.active
                    ? Qt.rgba(page.errorColor.r, page.errorColor.g, page.errorColor.b, 0.45)
                    : Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.3)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 9

                    Text {
                        text: "󰍬"
                        color: page.active ? page.errorColor : page.mutedColor
                        font.family: page.monoFont
                        font.pixelSize: 20
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            Layout.fillWidth: true
                            text: page.statusText
                            color: page.active ? page.errorColor : page.fgColor
                            font.family: page.monoFont
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: page.appText.length > 0
                            text: page.appText
                            color: page.mutedColor
                            font.family: page.monoFont
                            font.pixelSize: 9
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 62
                radius: 8
                color: Qt.rgba(page.errorColor.r, page.errorColor.g, page.errorColor.b, page.screenActive ? 0.14 : 0.04)
                border.width: 1
                border.color: page.screenActive
                    ? Qt.rgba(page.errorColor.r, page.errorColor.g, page.errorColor.b, 0.45)
                    : Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.3)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 9

                    Text {
                        text: "󰍹"
                        color: page.screenActive ? page.errorColor : page.mutedColor
                        font.family: page.monoFont
                        font.pixelSize: 20
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            Layout.fillWidth: true
                            text: page.screenStatusText
                            color: page.screenActive ? page.errorColor : page.fgColor
                            font.family: page.monoFont
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: page.screenAppText.length > 0
                            text: page.screenAppText
                            color: page.mutedColor
                            font.family: page.monoFont
                            font.pixelSize: 9
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Privacy indicators"
                description: "Master switch for privacy monitoring and indicators."
                checked: page.settings ? page.settings.privacyEnabled : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.privacyEnabled = !page.settings.privacyEnabled
            }

            Text {
                text: "RESOURCES"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Microphone"
                description: "Show when an application is capturing audio."
                checked: page.settings ? page.settings.privacyMicrophoneEnabled : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.privacyMicrophoneEnabled = !page.settings.privacyMicrophoneEnabled
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Screen sharing and recording"
                description: "Show when an application is capturing the screen through PipeWire."
                checked: page.settings ? page.settings.privacyScreenEnabled : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.privacyScreenEnabled = !page.settings.privacyScreenEnabled
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Show in collapsed Island"
                description: "Display the microphone indicator next to the collapsed items."
                checked: page.settings ? page.settings.privacyShowCollapsed : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.privacyShowCollapsed = !page.settings.privacyShowCollapsed
            }

            Text {
                text: "UNAVAILABLE DETECTION"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: 8
                color: Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.35)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        text: "󰄀"
                        color: page.mutedColor
                        font.family: page.monoFont
                        font.pixelSize: 14
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Camera detection"
                        color: page.fgColor
                        font.family: page.monoFont
                        font.pixelSize: 9
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "Not implemented"
                        color: page.mutedColor
                        font.family: page.monoFont
                        font.pixelSize: 8
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: "Microphone and screen monitoring are event-driven. Screen detection requires the application to expose a PipeWire capture stream with a Screen role; some applications may not provide enough metadata."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 8
                wrapMode: Text.Wrap
            }

            Item { implicitHeight: 2 }

            Rectangle {
                Layout.preferredWidth: 128
                Layout.preferredHeight: 28
                radius: 7
                color: restoreHover.hovered
                    ? Qt.rgba(page.accentColor.r, page.accentColor.g, page.accentColor.b, 0.2)
                    : Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.5)

                Text {
                    anchors.centerIn: parent
                    text: "RESTORE DEFAULTS"
                    color: restoreHover.hovered ? page.accentColor : page.mutedColor
                    font.family: page.monoFont
                    font.pixelSize: 7
                    font.weight: Font.Bold
                }

                HoverHandler {
                    id: restoreHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (page.settings) page.settings.resetPrivacy()
                }
            }
        }
    }
}
