import QtQuick
import QtQuick.Layouts

Item {
    id: page

    property var settings
    property string monoFont
    property color fgColor
    property color mutedColor
    property color accentColor
    property color onAccentColor
    property color surfaceHighColor

    Flickable {
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: content.implicitHeight

        ColumnLayout {
            id: content
            width: parent.width
            spacing: 7

            Text {
                text: "Power"
                color: page.fgColor
                font.family: page.monoFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: "System monitoring and battery thresholds. TLP remains untouched."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 9
                wrapMode: Text.Wrap
            }

            Text {
                text: "CPU"
                color: page.accentColor
                font.family: page.monoFont
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.4
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Refresh interval"
                value: page.settings ? page.settings.cpuRefreshInterval : 300
                from: 250
                to: 2000
                step: 50
                suffix: " ms"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.cpuRefreshInterval = value;
                }
            }

            Text {
                text: "BATTERY"
                color: page.accentColor
                font.family: page.monoFont
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.4
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Warning threshold"
                value: page.settings ? page.settings.batteryWarningThreshold : 20
                from: 5
                to: 50
                step: 5
                suffix: "%"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.batteryWarningThreshold = value;
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Critical threshold"
                value: page.settings ? page.settings.batteryCriticalThreshold : 10
                from: 1
                to: 20
                step: 1
                suffix: "%"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.batteryCriticalThreshold = value;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Preview critical indicator"
                description: "Show the red clock icon even when the battery is not low."
                checked: page.settings ? page.settings.batteryCriticalPreview : false
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.batteryCriticalPreview = !page.settings.batteryCriticalPreview;
                }
            }

            Text {
                Layout.fillWidth: true
                text: "The red icon appears next to the clock while the battery is at or below the critical threshold, until charging begins."
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
                    onClicked: if (page.settings) page.settings.resetPower()
                }
            }
        }
    }
}
