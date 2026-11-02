import QtQuick
import QtQuick.Layouts

// System actions: confirmation row, action list and error line.
// Shared by the full power menu and the actions-only menu. The list can render as
// rows (icon, label, description) or as a compact grid of tiles.
Item {
    id: grid

    property var powerActions
    property int selectedIndex: -1
    property string layoutMode: "rows"
    property string monoFont
    property real fontScale: 1
    property color fgColor
    property color mutedColor
    property color accentColor
    property color onAccentColor
    property color surfaceHighColor
    property color errorColor

    readonly property bool asGrid: grid.layoutMode === "grid"
    readonly property int columns: grid.asGrid ? 3 : 1

    implicitHeight: content.implicitHeight

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: 6

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            visible: grid.powerActions && grid.powerActions.pendingAction.length > 0
            radius: 8
            color: Qt.rgba(grid.errorColor.r, grid.errorColor.g, grid.errorColor.b, 0.14)
            border.width: 1
            border.color: grid.errorColor

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: grid.powerActions ? "Confirm " + grid.powerActions.pendingAction + "?" : ""
                    color: grid.fgColor
                    font.family: grid.monoFont
                    font.pixelSize: Math.round(10 * grid.fontScale)
                    elide: Text.ElideRight
                }

                Rectangle {
                    Layout.preferredWidth: 54
                    Layout.preferredHeight: 24
                    radius: 6
                    color: grid.surfaceHighColor

                    Text {
                        anchors.centerIn: parent
                        text: "CANCEL"
                        color: grid.mutedColor
                        font.family: grid.monoFont
                        font.pixelSize: Math.round(8 * grid.fontScale)
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (grid.powerActions) grid.powerActions.cancel()
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 54
                    Layout.preferredHeight: 24
                    radius: 6
                    color: grid.errorColor

                    Text {
                        anchors.centerIn: parent
                        text: "CONFIRM"
                        color: grid.onAccentColor
                        font.family: grid.monoFont
                        font.pixelSize: Math.round(8 * grid.fontScale)
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (grid.powerActions) grid.powerActions.confirm()
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: grid.columns
            columnSpacing: 6
            rowSpacing: 6

            Repeater {
                model: grid.powerActions ? grid.powerActions.visibleActions : []

                delegate: Rectangle {
                    id: actionItem

                    required property var modelData
                    required property int index

                    readonly property bool current: actionItem.index === grid.selectedIndex

                    Layout.fillWidth: true
                    Layout.preferredHeight: grid.asGrid ? 46 : 44
                    radius: 8
                    color: actionItem.current
                        ? Qt.rgba(grid.accentColor.r, grid.accentColor.g, grid.accentColor.b, 0.16)
                        : (actionHover.hovered
                            ? Qt.rgba(grid.accentColor.r, grid.accentColor.g, grid.accentColor.b, 0.10)
                            : grid.surfaceHighColor)
                    border.width: actionItem.current ? 1 : 0
                    border.color: grid.accentColor

                    // Grid mode: icon over label.
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2
                        visible: grid.asGrid

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: actionItem.modelData.icon
                            color: (actionItem.current || actionHover.hovered) ? grid.accentColor : grid.fgColor
                            font.family: grid.monoFont
                            font.pixelSize: Math.round(14 * grid.fontScale)
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: actionItem.modelData.label
                            color: actionItem.current ? grid.accentColor : grid.mutedColor
                            font.family: grid.monoFont
                            font.pixelSize: Math.round(8 * grid.fontScale)
                        }
                    }

                    // Row mode: icon, label and description.
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10
                        visible: !grid.asGrid

                        Text {
                            text: actionItem.modelData.icon
                            color: (actionItem.current || actionHover.hovered) ? grid.accentColor : grid.fgColor
                            font.family: grid.monoFont
                            font.pixelSize: Math.round(14 * grid.fontScale)
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                Layout.fillWidth: true
                                text: actionItem.modelData.label
                                color: actionItem.current ? grid.accentColor : grid.fgColor
                                font.family: grid.monoFont
                                font.pixelSize: Math.round(10 * grid.fontScale)
                                font.weight: actionItem.current ? Font.DemiBold : Font.Medium
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: actionItem.modelData.description
                                color: grid.mutedColor
                                font.family: grid.monoFont
                                font.pixelSize: Math.round(8 * grid.fontScale)
                                elide: Text.ElideRight
                            }
                        }
                    }

                    HoverHandler {
                        id: actionHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (grid.powerActions) {
                            grid.selectedIndex = actionItem.index;
                            grid.powerActions.request(actionItem.modelData.id);
                            if (actionItem.modelData.id === "lock")
                                grid.actionTriggered();
                        }
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            visible: grid.powerActions && grid.powerActions.lastError.length > 0
            text: grid.powerActions ? grid.powerActions.lastError : ""
            color: grid.errorColor
            font.family: grid.monoFont
            font.pixelSize: Math.round(8 * grid.fontScale)
            wrapMode: Text.WordWrap
        }
    }

    signal actionTriggered()
}
