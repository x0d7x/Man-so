import QtQuick
import QtQuick.Layouts

FocusScope {
    id: selector

    signal selected(string family)
    signal closeRequested()

    property string currentFont
    property string monoFont
    property color bgColor
    property color surfaceHighColor
    property color fgColor
    property color mutedColor
    property color accentColor
    property color onAccentColor
    property color borderMutedColor
    property string query: ""

    readonly property var families: {
        const list = Qt.fontFamilies();
        list.sort((a, b) => a.localeCompare(b));
        return list;
    }
    readonly property var filtered: {
        const q = selector.query.toLowerCase();
        if (q.length === 0)
            return selector.families;
        return selector.families.filter(family => family.toLowerCase().indexOf(q) !== -1);
    }

    anchors.fill: parent
    focus: visible
    visible: false
    z: 100

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: Qt.rgba(selector.bgColor.r, selector.bgColor.g, selector.bgColor.b, 0.99)
        border.width: 1
        border.color: selector.borderMutedColor

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 9

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                spacing: 8

                Text {
                    text: "SELECT FONT"
                    color: selector.accentColor
                    font.family: selector.monoFont
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 0.5
                }

                Item { Layout.fillWidth: true }

                Item {
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        color: selector.mutedColor
                        font.family: selector.monoFont
                        font.pixelSize: 13
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: selector.closeRequested()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                radius: 8
                color: Qt.rgba(selector.surfaceHighColor.r, selector.surfaceHighColor.g, selector.surfaceHighColor.b, 0.55)
                border.width: 1
                border.color: searchInput.activeFocus ? selector.accentColor : selector.borderMutedColor

                TextInput {
                    id: searchInput

                    anchors.fill: parent
                    anchors.leftMargin: 9
                    anchors.rightMargin: 9
                    verticalAlignment: TextInput.AlignVCenter
                    text: selector.query
                    color: selector.fgColor
                    selectionColor: selector.accentColor
                    selectedTextColor: selector.onAccentColor
                    font.family: selector.monoFont
                    font.pixelSize: 10
                    focus: selector.visible
                    onTextChanged: selector.query = text
                    Keys.onEscapePressed: selector.closeRequested()
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Choose a font family. Nerd Fonts preserve Island icon glyphs."
                    color: selector.mutedColor
                    font.family: selector.monoFont
                    font.pixelSize: 8
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: selector.filtered.length + " fonts"
                    color: selector.borderMutedColor
                    font.family: selector.monoFont
                    font.pixelSize: 8
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                model: selector.filtered

                delegate: Rectangle {
                    id: fontRow

                    required property var modelData

                    width: ListView.view.width
                    height: 30
                    radius: 7
                    color: fontRow.modelData === selector.currentFont
                        ? Qt.rgba(selector.accentColor.r, selector.accentColor.g, selector.accentColor.b, 0.8)
                        : (fontHover.hovered
                            ? Qt.rgba(selector.surfaceHighColor.r, selector.surfaceHighColor.g, selector.surfaceHighColor.b, 0.8)
                            : "transparent")

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 9
                        anchors.right: parent.right
                        anchors.rightMargin: 9
                        anchors.verticalCenter: parent.verticalCenter
                        text: fontRow.modelData
                        color: fontRow.modelData === selector.currentFont
                            ? selector.onAccentColor
                            : selector.fgColor
                        font.family: selector.monoFont
                        font.pixelSize: 9
                        elide: Text.ElideRight
                    }

                    HoverHandler {
                        id: fontHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: selector.selected(fontRow.modelData)
                    }
                }
            }
        }
    }

    Shortcut {
        sequence: "Esc"
        enabled: selector.visible
        onActivated: selector.closeRequested()
    }

    Timer {
        interval: 80
        running: selector.visible
        repeat: false
        onTriggered: {
            searchInput.forceActiveFocus();
            searchInput.selectAll();
        }
    }

    onVisibleChanged: {
        if (selector.visible) {
            selector.query = "";
            searchInput.forceActiveFocus();
        }
    }
}
