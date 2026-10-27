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

    readonly property var visibilityOptions: [
        { "key": "all", "label": "All" },
        { "key": "occupied", "label": "Occupied" },
        { "key": "active", "label": "Active" }
    ]

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
                text: "MangoWM"
                color: page.fgColor
                font.family: page.monoFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: "Workspace presentation only; MangoWM configuration is not modified."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 9
                wrapMode: Text.Wrap
            }

            Text {
                text: "WORKSPACE VISIBILITY"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: page.visibilityOptions

                    delegate: Rectangle {
                        id: visibilityButton

                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        radius: 7
                        color: page.settings && page.settings.workspaceVisibility === visibilityButton.modelData.key
                            ? page.accentColor
                            : (visibilityHover.hovered
                                ? Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.8)
                                : Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.4))

                        Text {
                            anchors.centerIn: parent
                            text: visibilityButton.modelData.label
                            color: page.settings && page.settings.workspaceVisibility === visibilityButton.modelData.key
                                ? page.onAccentColor
                                : page.fgColor
                            font.family: page.monoFont
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }

                        HoverHandler {
                            id: visibilityHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (page.settings)
                                    page.settings.workspaceVisibility = visibilityButton.modelData.key;
                            }
                        }
                    }
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Occupied indicators"
                description: "Show the small dot under workspaces containing clients."
                checked: page.settings ? page.settings.showOccupiedIndicator : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.showOccupiedIndicator = !page.settings.showOccupiedIndicator;
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Include urgent workspaces"
                description: "Keep urgent workspaces visible in Occupied and Active modes."
                checked: page.settings ? page.settings.includeUrgentWorkspaces : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: {
                    if (page.settings)
                        page.settings.includeUrgentWorkspaces = !page.settings.includeUrgentWorkspaces;
                }
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
                    onClicked: if (page.settings) page.settings.resetMango()
                }
            }
        }
    }
}
