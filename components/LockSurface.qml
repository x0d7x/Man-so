import Quickshell
import Quickshell.Wayland
import QtQuick

// One lock surface per screen. The background is opaque on purpose: a
// transparent lock is ignored by most compositors and defeats the point.
WlSessionLockSurface {
    id: surface

    property var lockState
    property var colors
    property var settings

    readonly property string monoFont: surface.settings && surface.settings.fontFamily.length > 0
        ? surface.settings.fontFamily
        : "JetBrainsMono Nerd Font Mono"
    readonly property color fgColor: surface.colors ? surface.colors.fg : "#ebdbb2"
    readonly property color mutedColor: surface.colors ? surface.colors.fgMuted : "#bdae93"
    readonly property color accentColor: surface.colors ? surface.colors.accent : "#fabd2f"
    readonly property color onAccentColor: surface.colors ? surface.colors.onAccent : "#282828"
    readonly property color surfaceColor: surface.colors ? surface.colors.surfaceContainer : "#3c3836"
    readonly property color errorColor: surface.colors ? surface.colors.error : "#fb4934"

    // Veila keeps the last wallpaper here; fall back to maneso's own state file.
    readonly property string wallpaperPath: {
        const home = Quickshell.env("HOME") || "";
        return home + "/.cache/veila/wallpaper.jpg";
    }

    property string password: ""

    color: "black"

    function submit() {
        if (!surface.lockState || surface.password.length === 0)
            return;
        surface.lockState.submit(surface.password);
        surface.password = "";
        passwordField.text = "";
        passwordField.forceActiveFocus();
    }

    onVisibleChanged: {
        if (surface.visible)
            Qt.callLater(() => passwordField.forceActiveFocus());
    }

    Component.onCompleted: Qt.callLater(() => passwordField.forceActiveFocus())

    Rectangle {
        anchors.fill: parent
        color: "black"

        Image {
            anchors.fill: parent
            source: "file://" + surface.wallpaperPath
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            smooth: true
        }

        // Dim the wallpaper so the clock and prompt stay readable.
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.55)
        }

        Column {
            anchors.centerIn: parent
            spacing: 18

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(clock.date, "HH:mm")
                color: surface.fgColor
                font.family: surface.monoFont
                font.pixelSize: 84
                font.weight: Font.Light
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(clock.date, "dddd, d MMMM")
                color: surface.mutedColor
                font.family: surface.monoFont
                font.pixelSize: 16
            }

            Item { width: 1; height: 10 }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 320
                height: 40
                radius: 10
                color: Qt.rgba(surface.surfaceColor.r, surface.surfaceColor.g, surface.surfaceColor.b, 0.92)
                border.width: 1
                border.color: passwordField.activeFocus ? surface.accentColor : Qt.rgba(1, 1, 1, 0.18)

                TextInput {
                    id: passwordField

                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
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
                    }
                }

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    verticalAlignment: Text.AlignVCenter
                    visible: passwordField.text.length === 0
                    text: "Password"
                    color: surface.mutedColor
                    font.family: surface.monoFont
                    font.pixelSize: 12
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 320
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

        // Small status line, also useful when debugging a lock that will not clear.
        Text {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 14
            text: surface.screen ? surface.screen.name : ""
                + (surface.lockState && surface.lockState.secure ? "  ·  secure" : "  ·  locking")
            color: surface.mutedColor
            font.family: surface.monoFont
            font.pixelSize: 9
        }
    }

    // Updates the clock once a minute while locked.
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
