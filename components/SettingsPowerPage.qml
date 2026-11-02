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

            Text {
                Layout.fillWidth: true
                text: "The red icon appears next to the clock while the battery is at or below the critical threshold, until charging begins."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 8
                wrapMode: Text.Wrap
            }

            Item { implicitHeight: 2 }

            Text {
                text: "IDLE"
                color: page.accentColor
                font.family: page.monoFont
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.4
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Idle handling"
                description: "Master switch for auto-lock and screen power-off. Also toggled by the power idle IPC."
                checked: page.settings ? page.settings.idleEnabled : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.idleEnabled = !page.settings.idleEnabled;
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Lock after"
                value: page.settings ? page.settings.idleLockMinutes : 5
                from: 0
                to: 60
                step: 1
                suffix: page.settings && page.settings.idleLockMinutes === 0 ? " (off)" : " min"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.idleLockMinutes = page.settings.clampIdleMinutes(value);
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Screens off after"
                value: page.settings ? page.settings.idleDisplayOffMinutes : 10
                from: 0
                to: 120
                step: 1
                suffix: page.settings && page.settings.idleDisplayOffMinutes === 0 ? " (off)" : " min"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.idleDisplayOffMinutes = page.settings.clampIdleMinutes(value);
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Pause idle while media plays"
                description: "Keep the session awake while something is playing."
                checked: page.settings ? page.settings.idleSuppressOnMedia : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.idleSuppressOnMedia = !page.settings.idleSuppressOnMedia;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Show icon when idle is off"
                description: "Show a small indicator in the collapsed island when both idle timers are off."
                checked: page.settings ? page.settings.showIdleOffIcon : false
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.showIdleOffIcon = !page.settings.showIdleOffIcon;
                }
            }

            Text {
                text: "ACTIONS PANEL"
                color: page.accentColor
                font.family: page.monoFont
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.4
            }

            SettingsChoiceRow {
                Layout.fillWidth: true
                label: "Look"
                options: [
                    { "key": "rows", "label": "Rows" },
                    { "key": "grid", "label": "Grid" }
                ]
                value: page.settings ? page.settings.powerActionsLayout : "rows"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onSelected: key => {
                    if (page.settings)
                        page.settings.powerActionsLayout = page.settings.clampPowerActionsLayout(key);
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Panel width"
                value: page.settings ? page.settings.powerActionsWidth : 380
                from: 240
                to: 640
                step: 10
                suffix: " px"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.powerActionsWidth = page.settings.clampPowerActionsWidth(value);
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Panel height"
                value: page.settings ? page.settings.powerActionsHeight : 316
                from: 120
                to: 640
                step: 10
                suffix: " px"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.powerActionsHeight = page.settings.clampPowerActionsHeight(value);
                }
            }

            Text {
                text: "POWER MENU"
                color: page.accentColor
                font.family: page.monoFont
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.4
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Confirm destructive actions"
                description: "Ask before suspend, logout, reboot or shutdown."
                checked: page.settings ? page.settings.powerRequireConfirm : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.powerRequireConfirm = !page.settings.powerRequireConfirm;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Show Lock"
                description: "Lock the session from the power menu."
                checked: page.settings ? page.settings.powerShowLock : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.powerShowLock = !page.settings.powerShowLock;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Show Suspend"
                description: "Suspend to RAM from the power menu."
                checked: page.settings ? page.settings.powerShowSuspend : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.powerShowSuspend = !page.settings.powerShowSuspend;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Show Logout"
                description: "End the MangoWM session."
                checked: page.settings ? page.settings.powerShowLogout : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.powerShowLogout = !page.settings.powerShowLogout;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Show Reboot"
                description: "Restart the machine."
                checked: page.settings ? page.settings.powerShowReboot : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.powerShowReboot = !page.settings.powerShowReboot;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Show Shutdown"
                description: "Power the machine off."
                checked: page.settings ? page.settings.powerShowShutdown : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.powerShowShutdown = !page.settings.powerShowShutdown;
                }
            }

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
