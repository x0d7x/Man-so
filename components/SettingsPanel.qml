import QtQuick
import QtQuick.Layouts

FocusScope {
    id: panel

    signal closeRequested()

    property string monoFont
    property color surfaceHighColor
    property color fgColor
    property color mutedColor
    property color accentColor
    property color onAccentColor
    property color borderMutedColor
    property var diagnostics
    property var settings

    property int currentPage: 0
    readonly property var navItems: [
        { "label": "General", "icon": "󰒓" },
        { "label": "About", "icon": "󰋼" },
        { "label": "Diagnostics", "icon": "󰓅" }
    ]

    anchors.fill: parent
    focus: visible

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: {}
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            spacing: 8

            Item {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: backHover.hovered
                        ? Qt.rgba(panel.surfaceHighColor.r, panel.surfaceHighColor.g, panel.surfaceHighColor.b, 0.9)
                        : Qt.rgba(panel.surfaceHighColor.r, panel.surfaceHighColor.g, panel.surfaceHighColor.b, 0.5)
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰁍"
                    color: panel.fgColor
                    font.family: panel.monoFont
                    font.pixelSize: 15
                }

                HoverHandler {
                    id: backHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: panel.closeRequested()
                }
            }

            Text {
                text: "SETTINGS"
                color: panel.accentColor
                font.family: panel.monoFont
                font.pixelSize: 11
                font.weight: Font.Bold
                font.letterSpacing: 0.6
            }

            Item {
                Layout.fillWidth: true
            }

            Item {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: closeHover.hovered
                        ? Qt.rgba(panel.surfaceHighColor.r, panel.surfaceHighColor.g, panel.surfaceHighColor.b, 0.9)
                        : Qt.rgba(panel.surfaceHighColor.r, panel.surfaceHighColor.g, panel.surfaceHighColor.b, 0.5)
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    color: panel.mutedColor
                    font.family: panel.monoFont
                    font.pixelSize: 13
                }

                HoverHandler {
                    id: closeHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: panel.closeRequested()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: panel.borderMutedColor
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            ColumnLayout {
                Layout.fillWidth: false
                Layout.minimumWidth: 112
                Layout.preferredWidth: 112
                Layout.maximumWidth: 112
                Layout.fillHeight: true
                spacing: 5

                Text {
                    text: "CATEGORIES"
                    color: panel.mutedColor
                    font.family: panel.monoFont
                    font.pixelSize: 7
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.5
                    Layout.leftMargin: 8
                    Layout.bottomMargin: 2
                }

                Repeater {
                    model: panel.navItems

                    delegate: Rectangle {
                        id: navItem

                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        radius: 8
                        color: panel.currentPage === navItem.index
                            ? panel.accentColor
                            : (navHover.hovered
                                ? Qt.rgba(panel.surfaceHighColor.r, panel.surfaceHighColor.g, panel.surfaceHighColor.b, 0.75)
                                : "transparent")

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 9
                            anchors.rightMargin: 9
                            spacing: 7

                            Text {
                                text: navItem.modelData.icon
                                color: panel.currentPage === navItem.index
                                    ? panel.onAccentColor
                                    : panel.accentColor
                                font.family: panel.monoFont
                                font.pixelSize: 13
                            }

                            Text {
                                Layout.fillWidth: true
                                text: navItem.modelData.label
                                color: panel.currentPage === navItem.index
                                    ? panel.onAccentColor
                                    : panel.fgColor
                                font.family: panel.monoFont
                                font.pixelSize: 10
                                font.weight: panel.currentPage === navItem.index
                                    ? Font.DemiBold
                                    : Font.Normal
                                elide: Text.ElideRight
                            }
                        }

                        HoverHandler {
                            id: navHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: panel.currentPage = navItem.index
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                Text {
                    Layout.leftMargin: 8
                    text: "man-qs"
                    color: panel.borderMutedColor
                    font.family: panel.monoFont
                    font.pixelSize: 8
                }
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                color: panel.borderMutedColor
            }

            Item {
                id: pageContainer

                Layout.fillWidth: true
                Layout.fillHeight: true
                opacity: 1

                SettingsGeneralPage {
                    anchors.fill: parent
                    visible: panel.currentPage === 0
                    settings: panel.settings
                    monoFont: panel.monoFont
                    fgColor: panel.fgColor
                    mutedColor: panel.mutedColor
                    accentColor: panel.accentColor
                    onAccentColor: panel.onAccentColor
                    surfaceHighColor: panel.surfaceHighColor
                }

                SettingsAboutPage {
                    anchors.fill: parent
                    visible: panel.currentPage === 1
                    diagnostics: panel.diagnostics
                    monoFont: panel.monoFont
                    fgColor: panel.fgColor
                    mutedColor: panel.mutedColor
                    accentColor: panel.accentColor
                    surfaceHighColor: panel.surfaceHighColor
                }

                SettingsDiagnosticsPage {
                    anchors.fill: parent
                    visible: panel.currentPage === 2
                    diagnostics: panel.diagnostics
                    settings: panel.settings
                    monoFont: panel.monoFont
                    fgColor: panel.fgColor
                    mutedColor: panel.mutedColor
                    accentColor: panel.accentColor
                    onAccentColor: panel.onAccentColor
                    surfaceHighColor: panel.surfaceHighColor
                }
            }
        }
    }

    Keys.onUpPressed: {
        panel.currentPage = Math.max(0, panel.currentPage - 1);
    }

    Keys.onDownPressed: {
        panel.currentPage = Math.min(panel.navItems.length - 1, panel.currentPage + 1);
    }

    function syncPageFromSettings() {
        if (!panel.settings)
            return;
        const next = Math.max(0, Math.min(panel.navItems.length - 1, panel.settings.settingsPage));
        if (panel.currentPage !== next)
            panel.currentPage = next;
    }

    onSettingsChanged: syncPageFromSettings()

    onCurrentPageChanged: {
        if (panel.settings && panel.settings.settingsPage !== panel.currentPage)
            panel.settings.settingsPage = panel.currentPage;
        if (!pageContainer)
            return;
        pageContainer.opacity = 0;
        pageFade.restart();
    }

    Connections {
        target: panel.settings

        function onSettingsPageChanged() {
            panel.syncPageFromSettings();
        }
    }

    NumberAnimation {
        id: pageFade
        target: pageContainer
        property: "opacity"
        from: 0
        to: 1
        duration: 150
        easing.type: Easing.OutCubic
    }

    Shortcut {
        sequence: "Esc"
        enabled: panel.visible
        onActivated: panel.closeRequested()
    }

    Timer {
        interval: 100
        running: panel.visible
        repeat: false
        onTriggered: panel.forceActiveFocus()
    }

    Keys.onEscapePressed: panel.closeRequested()

    onVisibleChanged: {
        if (panel.visible) {
            panel.syncPageFromSettings();
            Qt.callLater(() => panel.forceActiveFocus());
        }
    }
}
