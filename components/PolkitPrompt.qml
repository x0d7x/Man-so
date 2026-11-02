import QtQuick
import QtQuick.Layouts

// Password prompt for a polkit authentication request, shown inside the island.
// The password lives only in this item's property and is cleared as soon as it is
// submitted, cancelled, or the request ends. It is never written anywhere.
FocusScope {
    id: prompt

    property var polkit
    property string monoFont
    property real fontScale: 1
    property color fgColor
    property color mutedColor
    property color accentColor
    property color onAccentColor
    property color errorColor
    property color surfaceHighColor
    property color borderMutedColor

    property string password: ""

    readonly property string message: prompt.polkit ? prompt.polkit.message : ""
    readonly property string actionId: prompt.polkit ? prompt.polkit.actionId : ""
    readonly property string inputPrompt: prompt.polkit ? prompt.polkit.inputPrompt : ""
    readonly property string supplementary: prompt.polkit ? prompt.polkit.supplementaryMessage : ""
    readonly property bool supplementaryIsError: prompt.polkit ? prompt.polkit.supplementaryIsError : false
    readonly property bool responseRequired: prompt.polkit ? prompt.polkit.responseRequired : false
    readonly property bool responseVisible: prompt.polkit ? prompt.polkit.responseVisible : false
    readonly property bool failed: prompt.polkit ? prompt.polkit.failed : false
    // polkit reports a failed attempt through `failed` and may leave the
    // supplementary message empty, so show a fallback error ourselves.
    readonly property string errorText: prompt.supplementary.length > 0
        ? prompt.supplementary
        : (prompt.failed ? "Authentication failed. Try again." : "")

    function clearPassword() {
        prompt.password = "";
        passwordField.text = "";
    }

    function submit() {
        if (!prompt.polkit)
            return;
        if (prompt.responseRequired) {
            if (prompt.password.length === 0)
                return;
            prompt.polkit.submit(prompt.password);
        } else {
            // Some requests only need confirmation.
            prompt.polkit.submit("");
        }
        prompt.clearPassword();
    }

    function cancel() {
        prompt.clearPassword();
        if (prompt.polkit)
            prompt.polkit.cancel();
    }

    // Focus the field whenever a response is asked for.
    onResponseRequiredChanged: {
        if (prompt.responseRequired)
            Qt.callLater(() => passwordField.forceActiveFocus());
    }

    Component.onCompleted: {
        if (prompt.responseRequired)
            Qt.callLater(() => passwordField.forceActiveFocus());
    }

    // Never keep a typed password around once the request is over.
    onVisibleChanged: if (!visible)
        prompt.clearPassword()

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: {}
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "󰌾"
                color: prompt.accentColor
                font.family: prompt.monoFont
                font.pixelSize: Math.round(14 * prompt.fontScale)
            }

            Text {
                Layout.fillWidth: true
                text: "Authentication required"
                color: prompt.fgColor
                font.family: prompt.monoFont
                font.pixelSize: Math.round(12 * prompt.fontScale)
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
        }

        Text {
            Layout.fillWidth: true
            text: prompt.message
            color: prompt.fgColor
            font.family: prompt.monoFont
            font.pixelSize: Math.round(10 * prompt.fontScale)
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            visible: prompt.actionId.length > 0
            text: prompt.actionId
            color: prompt.mutedColor
            font.family: prompt.monoFont
            font.pixelSize: Math.round(8 * prompt.fontScale)
            elide: Text.ElideMiddle
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            visible: prompt.responseRequired
            radius: 8
            color: prompt.surfaceHighColor
            border.width: 1
            border.color: passwordField.activeFocus ? prompt.accentColor : prompt.borderMutedColor

            TextInput {
                id: passwordField

                anchors.fill: parent
                anchors.leftMargin: 9
                anchors.rightMargin: 9
                verticalAlignment: TextInput.AlignVCenter
                color: prompt.fgColor
                selectionColor: prompt.accentColor
                selectedTextColor: prompt.onAccentColor
                font.family: prompt.monoFont
                font.pixelSize: Math.round(12 * prompt.fontScale)
                echoMode: prompt.responseVisible ? TextInput.Normal : TextInput.Password
                passwordCharacter: "●"
                focus: prompt.responseRequired
                onTextChanged: {
                    if (prompt.password !== text)
                        prompt.password = text;
                }
                onAccepted: prompt.submit()
                Keys.onEscapePressed: prompt.cancel()
            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: 9
                verticalAlignment: Text.AlignVCenter
                visible: passwordField.text.length === 0
                text: prompt.inputPrompt.length > 0 ? prompt.inputPrompt : "Password"
                color: prompt.mutedColor
                font.family: prompt.monoFont
                font.pixelSize: Math.round(10 * prompt.fontScale)
            }
        }

        Text {
            Layout.fillWidth: true
            visible: prompt.errorText.length > 0
            text: prompt.errorText
            color: prompt.failed || prompt.supplementaryIsError ? prompt.errorColor : prompt.mutedColor
            font.family: prompt.monoFont
            font.pixelSize: Math.round(9 * prompt.fontScale)
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: 84
                Layout.preferredHeight: 30
                radius: 8
                color: cancelHover.hovered
                    ? Qt.rgba(prompt.accentColor.r, prompt.accentColor.g, prompt.accentColor.b, 0.2)
                    : prompt.surfaceHighColor

                Text {
                    anchors.centerIn: parent
                    text: "CANCEL"
                    color: prompt.fgColor
                    font.family: prompt.monoFont
                    font.pixelSize: Math.round(9 * prompt.fontScale)
                    font.weight: Font.DemiBold
                }

                HoverHandler {
                    id: cancelHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: prompt.cancel()
                }
            }

            Rectangle {
                Layout.preferredWidth: 104
                Layout.preferredHeight: 30
                radius: 8
                color: prompt.password.length > 0 || !prompt.responseRequired
                    ? prompt.accentColor
                    : prompt.surfaceHighColor

                Text {
                    anchors.centerIn: parent
                    text: "AUTHENTICATE"
                    color: prompt.password.length > 0 || !prompt.responseRequired
                        ? prompt.onAccentColor
                        : prompt.mutedColor
                    font.family: prompt.monoFont
                    font.pixelSize: Math.round(9 * prompt.fontScale)
                    font.weight: Font.Bold
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: prompt.submit()
                }
            }
        }
    }
}
