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

    readonly property var clockFormats: [
        { "key": "24h", "label": "24h" },
        { "key": "12h", "label": "12h" }
    ]

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
                text: "Lock screen"
                color: page.fgColor
                font.family: page.monoFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: "Appearance and content of the session lock. Authentication always uses PAM."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 9
                wrapMode: Text.Wrap
            }
            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Blur wallpaper"
                description: "Blur the lock background instead of showing it sharply."
                checked: page.settings ? page.settings.lockBlurEnabled : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.lockBlurEnabled = !page.settings.lockBlurEnabled;
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                visible: page.settings ? page.settings.lockBlurEnabled : true
                label: "Blur amount"
                value: page.settings ? page.settings.lockBlurAmount : 45
                from: 0
                to: 100
                step: 5
                suffix: " %"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.lockBlurAmount = page.settings.clampLockBlurAmount(value);
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Darken"
                value: page.settings ? page.settings.lockDim : 55
                from: 0
                to: 90
                step: 5
                suffix: " %"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.lockDim = page.settings.clampLockDim(value);
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Clock size"
                value: page.settings ? page.settings.lockClockScale : 100
                from: 60
                to: 160
                step: 5
                suffix: " %"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.lockClockScale = page.settings.clampLockClockScale(value);
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Show clock"
                description: "Large time in the middle of the lock screen."
                checked: page.settings ? page.settings.lockShowClock : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.lockShowClock = !page.settings.lockShowClock;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Show date"
                description: "Weekday and date under the clock."
                checked: page.settings ? page.settings.lockShowDate : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.lockShowDate = !page.settings.lockShowDate;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Show screen name"
                description: "Small monitor name and lock state in the corner."
                checked: page.settings ? page.settings.lockShowScreenLabel : false
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.lockShowScreenLabel = !page.settings.lockShowScreenLabel;
                }
            }


            Text {
                text: "CLOCK"
                color: page.accentColor
                font.family: page.monoFont
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.4
            }

            SettingsChoiceRow {
                Layout.fillWidth: true
                label: "Time format"
                options: page.clockFormats
                value: page.settings ? page.settings.lockClockFormat : "24h"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onSelected: key => {
                    if (page.settings)
                        page.settings.lockClockFormat = page.settings.clampLockClockFormat(key);
                }
            }

            SettingsTextRow {
                Layout.fillWidth: true
                label: "Date format"
                description: "Qt date pattern, for example dddd, d MMMM."
                value: page.settings ? page.settings.lockDateFormat : "dddd, d MMMM"
                placeholder: "dddd, d MMMM"
                maximumLength: 40
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onCommitted: text => {
                    if (page.settings)
                        page.settings.lockDateFormat = page.settings.clampLockDateFormat(text);
                }
            }

            Text {
                text: "CONTENT"
                color: page.accentColor
                font.family: page.monoFont
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.4
            }
            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Media controls"
                description: "Track title and playback buttons while something is playing."
                checked: page.settings ? page.settings.lockShowMedia : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.lockShowMedia = !page.settings.lockShowMedia;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Battery"
                description: "Battery percentage and charging state."
                checked: page.settings ? page.settings.lockShowBattery : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.lockShowBattery = !page.settings.lockShowBattery;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "User name and avatar"
                description: "Account name and picture above the clock."
                checked: page.settings ? page.settings.lockShowAvatar : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.lockShowAvatar = !page.settings.lockShowAvatar;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Caps Lock warning"
                description: "Warn while Caps Lock is on (needs a keyboard LED)."
                checked: page.settings ? page.settings.lockShowCapsLock : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.lockShowCapsLock = !page.settings.lockShowCapsLock;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Attempt counter"
                description: "Show how many attempts have failed."
                checked: page.settings ? page.settings.lockShowAttempts : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.lockShowAttempts = !page.settings.lockShowAttempts;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Failure animation"
                description: "Shake the prompt after a wrong password."
                checked: page.settings ? page.settings.lockAnimateFailure : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.lockAnimateFailure = !page.settings.lockAnimateFailure;
                }
            }

        }
    }
}
