import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects

// One lock surface per screen. The background is opaque on purpose: a
// transparent lock is ignored by most compositors and defeats the point.
WlSessionLockSurface {
    id: surface

    property var lockState
    property var colors
    property var settings
    property var media
    property var stats

    readonly property string monoFont: surface.settings && surface.settings.fontFamily.length > 0
        ? surface.settings.fontFamily
        : "JetBrainsMono Nerd Font Mono"
    readonly property color fgColor: surface.colors ? surface.colors.fg : "#ebdbb2"
    readonly property color mutedColor: surface.colors ? surface.colors.fgMuted : "#bdae93"
    readonly property color accentColor: surface.colors ? surface.colors.accent : "#fabd2f"
    readonly property color onAccentColor: surface.colors ? surface.colors.onAccent : "#282828"
    readonly property color surfaceColor: surface.colors ? surface.colors.surfaceContainer : "#3c3636"
    readonly property color errorColor: surface.colors ? surface.colors.error : "#fb4934"

    readonly property bool blurEnabled: surface.settings ? surface.settings.lockBlurEnabled : true
    readonly property real blurAmount: surface.settings ? surface.settings.lockBlurAmount / 100 : 0.45
    readonly property real dimAmount: surface.settings ? surface.settings.lockDim / 100 : 0.55
    readonly property bool showClock: surface.settings ? surface.settings.lockShowClock : true
    readonly property bool showDate: surface.settings ? surface.settings.lockShowDate : true
    readonly property real clockScale: surface.settings ? surface.settings.lockClockScale / 100 : 1
    readonly property bool showScreenLabel: surface.settings ? surface.settings.lockShowScreenLabel : false
    readonly property bool showMedia: surface.settings ? surface.settings.lockShowMedia : true
    readonly property bool showBattery: surface.settings ? surface.settings.lockShowBattery : true
    readonly property bool showAvatar: surface.settings ? surface.settings.lockShowAvatar : true
    readonly property bool showCapsLock: surface.settings ? surface.settings.lockShowCapsLock : true
    readonly property bool showAttempts: surface.settings ? surface.settings.lockShowAttempts : true
    readonly property bool animateFailure: surface.settings ? surface.settings.lockAnimateFailure : true
    readonly property string timeFormat: surface.settings && surface.settings.lockClockFormat === "12h" ? "hh:mm AP" : "HH:mm"
    readonly property string dateFormat: surface.settings ? surface.settings.lockDateFormat : "dddd, d MMMM"
    readonly property string userName: Quickshell.env("USER") || "user"
    readonly property string avatarPath: "/var/lib/AccountsService/icons/" + surface.userName
    readonly property bool capsLockOn: surface.capsPath.length > 0 && capsFile.text().trim() === "1"
    readonly property bool mediaActive: surface.showMedia && surface.media && surface.media.hasPlayer
    readonly property bool batteryVisible: surface.showBattery && surface.stats && surface.stats.batteryPercent >= 0

    property string capsPath: ""
    property real shakeOffset: 0
    property real failPulse: 0

    // Veila keeps the last wallpaper here.
    readonly property string wallpaperPath: (Quickshell.env("HOME") || "") + "/.cache/veila/wallpaper.jpg"

    property string password: ""
    property bool revealPassword: false

    color: "black"

    function submit() {
        if (!surface.lockState || surface.password.length === 0)
            return;
        surface.lockState.submit(surface.password);
        surface.password = "";
        surface.revealPassword = false;
        passwordField.text = "";
        passwordField.echoMode = TextInput.Password;
        passwordField.forceActiveFocus();
    }

    onVisibleChanged: {
        if (surface.visible) {
            Qt.callLater(() => passwordField.forceActiveFocus());
        } else {
            // Never keep a revealed password around after the lock ends.
            surface.password = "";
            surface.revealPassword = false;
        }
    }

    Component.onCompleted: Qt.callLater(() => passwordField.forceActiveFocus())

    Rectangle {
        anchors.fill: parent
        color: "black"

        // Wallpaper, blurred when the setting asks for it. MultiEffect needs the
        // source item to be layered.
        Item {
            id: background

            anchors.fill: parent
            layer.enabled: surface.blurEnabled
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: surface.blurAmount
                blurMax: 64
            }

            Image {
                anchors.fill: parent
                source: "file://" + surface.wallpaperPath
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
                smooth: true
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, surface.dimAmount)
        }

        Column {
            anchors.centerIn: parent
            spacing: 18

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                visible: surface.showAvatar

                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    clip: true
                    color: Qt.rgba(1, 1, 1, 0.12)

                    Image {
                        id: avatar

                        anchors.fill: parent
                        source: "file://" + surface.avatarPath
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: false
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !avatar.visible
                        text: surface.userName.length > 0 ? surface.userName.charAt(0).toUpperCase() : "?"
                        color: surface.fgColor
                        font.family: surface.monoFont
                        font.pixelSize: 18
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: surface.userName
                    color: surface.fgColor
                    font.family: surface.monoFont
                    font.pixelSize: 14
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: surface.showClock
                text: Qt.formatTime(clock.date, surface.timeFormat)
                color: surface.fgColor
                font.family: surface.monoFont
                font.pixelSize: Math.round(84 * surface.clockScale)
                font.weight: Font.Light
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: surface.showDate
                text: Qt.formatDate(clock.date, surface.dateFormat)
                color: surface.mutedColor
                font.family: surface.monoFont
                font.pixelSize: Math.round(16 * surface.clockScale)
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8
                visible: surface.mediaActive

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 210
                    text: surface.media
                        ? (surface.media.title + (surface.media.artist.length > 0 ? "  ·  " + surface.media.artist : ""))
                        : ""
                    color: surface.fgColor
                    font.family: surface.monoFont
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignRight
                }

                Repeater {
                    model: [
                        { "icon": "󰒮", "action": "previous" },
                        { "icon": "󰐎", "action": "toggle" },
                        { "icon": "󰒭", "action": "next" }
                    ]

                    delegate: Rectangle {
                        id: mediaButton

                        required property var modelData

                        width: 26
                        height: 26
                        radius: 7
                        anchors.verticalCenter: parent.verticalCenter
                        color: mediaHover.hovered ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: mediaButton.modelData.icon
                            color: surface.mutedColor
                            font.family: surface.monoFont
                            font.pixelSize: 13
                        }

                        HoverHandler {
                            id: mediaHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!surface.media)
                                    return;
                                if (mediaButton.modelData.action === "next") {
                                    surface.media.next();
                                } else if (mediaButton.modelData.action === "previous") {
                                    surface.media.previous();
                                } else {
                                    surface.media.togglePlaying();
                                }
                                passwordField.forceActiveFocus();
                            }
                        }
                    }
                }
            }

            Item {
                width: 1
                height: (surface.showClock || surface.showDate) ? 10 : 0
            }

            Rectangle {
                id: prompt

                anchors.horizontalCenter: parent.horizontalCenter
                width: 340
                height: 40
                radius: 10
                transform: Translate { x: surface.shakeOffset }
                color: Qt.rgba(surface.surfaceColor.r, surface.surfaceColor.g, surface.surfaceColor.b, 0.92)
                border.width: 1
                border.color: passwordField.activeFocus ? surface.accentColor : Qt.rgba(1, 1, 1, 0.18)

                TextInput {
                    id: passwordField

                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 44
                    verticalAlignment: TextInput.AlignVCenter
                    color: surface.fgColor
                    selectionColor: surface.accentColor
                    selectedTextColor: surface.onAccentColor
                    font.family: surface.monoFont
                    font.pixelSize: 13
                    echoMode: TextInput.Password
                    passwordCharacter: "●"
                    focus: true
                    onTextChanged: {
                        if (surface.password !== text)
                            surface.password = text;
                    }
                    onAccepted: surface.submit()
                    Keys.onEscapePressed: {
                        text = "";
                        surface.password = "";
                        surface.revealPassword = false;
                        passwordField.echoMode = TextInput.Password;
                    }
                }

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 44
                    verticalAlignment: Text.AlignVCenter
                    visible: passwordField.text.length === 0
                    text: "Password"
                    color: surface.mutedColor
                    font.family: surface.monoFont
                    font.pixelSize: 12
                }

                // Reveal toggle: shows the typed password while held.
                Rectangle {
                    id: revealButton

                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    width: 30
                    height: 28
                    radius: 7
                    color: surface.revealPassword
                        ? Qt.rgba(surface.accentColor.r, surface.accentColor.g, surface.accentColor.b, 0.22)
                        : (revealHover.hovered ? Qt.rgba(1, 1, 1, 0.10) : "transparent")

                    Text {
                        anchors.centerIn: parent
                        text: surface.revealPassword ? "󰈈" : "󰈉"
                        color: surface.revealPassword ? surface.accentColor : surface.mutedColor
                        font.family: surface.monoFont
                        font.pixelSize: 14
                    }

                    HoverHandler {
                        id: revealHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            surface.revealPassword = !surface.revealPassword;
                            passwordField.echoMode = surface.revealPassword
                                ? TextInput.Normal
                                : TextInput.Password;
                            passwordField.forceActiveFocus();
                        }
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: surface.showCapsLock && surface.capsLockOn
                text: "󰪛 Caps Lock is on"
                color: surface.accentColor
                font.family: surface.monoFont
                font.pixelSize: 10
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: surface.showAttempts && surface.lockState && surface.lockState.attempts > 0
                text: surface.lockState
                    ? (surface.lockState.attempts === 1
                        ? "1 failed attempt"
                        : surface.lockState.attempts + " failed attempts")
                    : ""
                color: surface.mutedColor
                font.family: surface.monoFont
                font.pixelSize: 10
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 340
                horizontalAlignment: Text.AlignHCenter
                visible: surface.lockState && surface.lockState.errorText.length > 0
                text: surface.lockState ? surface.lockState.errorText : ""
                color: surface.errorColor
                font.family: surface.monoFont
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: surface.lockState && surface.lockState.authenticating
                    ? "Authenticating…"
                    : "Enter to unlock"
                color: surface.mutedColor
                font.family: surface.monoFont
                font.pixelSize: 10
            }
        }

        Row {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 14
            spacing: 6
            visible: surface.batteryVisible

            Text {
                text: surface.stats ? surface.stats.batteryIcon : ""
                color: surface.mutedColor
                font.family: surface.monoFont
                font.pixelSize: 12
            }

            Text {
                text: surface.stats ? surface.stats.batteryText : ""
                color: surface.mutedColor
                font.family: surface.monoFont
                font.pixelSize: 10
            }
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 14
            visible: surface.showScreenLabel
            text: surface.screen ? surface.screen.name : ""
                + (surface.lockState && surface.lockState.secure ? "  ·  secure" : "  ·  locking")
            color: surface.mutedColor
            font.family: surface.monoFont
            font.pixelSize: 9
        }
    }

    // Caps Lock has no Wayland API; the keyboard LED is the practical source.
    // Best effort: the warning stays hidden when no LED exists.
    Process {
        running: true
        command: ["sh", "-c", "ls /sys/class/leds/*::capslock/brightness 2>/dev/null | head -1"]

        stdout: StdioCollector {
            onStreamFinished: surface.capsPath = this.text.trim()
        }
    }

    FileView {
        id: capsFile

        path: surface.capsPath.length > 0 ? surface.capsPath : "/dev/null"
        watchChanges: true

        onFileChanged: reload()
    }

    Connections {
        target: surface.lockState

        function onAttemptsChanged() {
            if (surface.animateFailure && surface.lockState && surface.lockState.attempts > 0)
                shakeAnimation.restart();
        }
    }

    SequentialAnimation {
        id: shakeAnimation

        NumberAnimation { target: surface; property: "shakeOffset"; to: 10; duration: 60 }
        NumberAnimation { target: surface; property: "shakeOffset"; to: -10; duration: 60 }
        NumberAnimation { target: surface; property: "shakeOffset"; to: 6; duration: 50 }
        NumberAnimation { target: surface; property: "shakeOffset"; to: 0; duration: 80 }
    }

    // Keeps the clock current while locked.
    QtObject {
        id: clock

        property date date: new Date()

        property var timer: Timer {
            interval: 1000
            running: surface.visible
            repeat: true
            onTriggered: clock.date = new Date()
        }
    }
}
