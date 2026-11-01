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

    readonly property var clockOption: { "key": "time", "label": "Clock", "icon": "󰥔" }
    readonly property var collapsedOptions: [
        { "key": "date", "label": "Date", "icon": "󰃭" },
        { "key": "workspace", "label": "Workspace", "icon": "󰅬" },
        { "key": "window", "label": "Window", "icon": "󰖲" },
        { "key": "layout", "label": "Layout", "icon": "󰕴" },
        { "key": "cpu", "label": "CPU", "icon": "󰻠" },
        { "key": "ram", "label": "RAM", "icon": "󰍛" },
        { "key": "temp", "label": "Temp", "icon": "󰔏" },
        { "key": "battery", "label": "Battery", "icon": "󰁹" },
        { "key": "wifi", "label": "Wi-Fi", "icon": "󰤨" },
        { "key": "bluetooth", "label": "Bluetooth", "icon": "󰂯" },
        { "key": "power", "label": "Power", "icon": "󰾅" },
        { "key": "volume", "label": "Volume", "icon": "󰕾" },
        { "key": "brightness", "label": "Brightness", "icon": "󰃠" },
        { "key": "externalBrightness", "label": "Ext. brightness", "icon": "󰃠" },
        { "key": "media", "label": "Media", "icon": "󰎆" },
        { "key": "notifications", "label": "Notifications", "icon": "󰂚" },
        { "key": "tray", "label": "Tray", "icon": "󰀻" }
    ]

    function optionInfo(key) {
        if (key === "time")
            return page.clockOption;
        for (let i = 0; i < page.collapsedOptions.length; ++i) {
            if (page.collapsedOptions[i].key === key)
                return page.collapsedOptions[i];
        }
        return { "key": key, "label": key, "icon": "" };
    }

    function dateExample(pattern) {
        return Qt.formatDate(new Date(), pattern);
    }

    Flickable {
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: content.implicitHeight

        ColumnLayout {
            id: content
            width: parent.width
            spacing: 6

            Text {
                text: "Island"
                color: page.fgColor
                font.family: page.monoFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: "What the collapsed pill shows, in which order, and how the date looks."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 9
                wrapMode: Text.Wrap
            }

            Text {
                text: "COLLAPSED ITEMS"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            Text {
                Layout.fillWidth: true
                text: "Selected items appear in the collapsed Island. Drag the arrows below to order them."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 8
                wrapMode: Text.Wrap
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 6
                rowSpacing: 6

                Repeater {
                    model: page.collapsedOptions

                    delegate: Rectangle {
                        id: collapsedChip

                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        radius: 7
                        color: page.settings && page.settings.hasCollapsedItem(collapsedChip.modelData.key)
                            ? page.accentColor
                            : (collapsedHover.hovered
                                ? Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.8)
                                : Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.4))

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 6

                            Text {
                                text: collapsedChip.modelData.icon
                                color: page.settings && page.settings.hasCollapsedItem(collapsedChip.modelData.key)
                                    ? page.onAccentColor
                                    : page.accentColor
                                font.family: page.monoFont
                                font.pixelSize: 12
                            }

                            Text {
                                Layout.fillWidth: true
                                text: collapsedChip.modelData.label
                                color: page.settings && page.settings.hasCollapsedItem(collapsedChip.modelData.key)
                                    ? page.onAccentColor
                                    : page.fgColor
                                font.family: page.monoFont
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                        }

                        HoverHandler {
                            id: collapsedHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (page.settings) page.settings.toggleCollapsedItem(collapsedChip.modelData.key)
                        }
                    }
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Privacy indicator"
                description: "Show microphone and screen activity in the collapsed Island."
                checked: page.settings ? page.settings.privacyShowCollapsed : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.privacyShowCollapsed = !page.settings.privacyShowCollapsed
            }

            Text {
                text: "ORDER"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            Text {
                Layout.fillWidth: true
                text: "Move items, including the clock, left or right."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 8
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: page.settings ? page.settings.collapsedItems : ["time"]

                    delegate: Rectangle {
                        id: orderRow

                        required property string modelData
                        required property int index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 27
                        radius: 7
                        color: Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.35)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 6
                            spacing: 6

                            Text {
                                text: page.optionInfo(orderRow.modelData).icon
                                color: page.accentColor
                                font.family: page.monoFont
                                font.pixelSize: 11
                            }

                            Text {
                                Layout.fillWidth: true
                                text: page.optionInfo(orderRow.modelData).label
                                color: page.fgColor
                                font.family: page.monoFont
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                            }

                            Item {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                opacity: orderRow.index > 0 ? 1 : 0.3

                                Text {
                                    anchors.centerIn: parent
                                    text: "←"
                                    color: page.mutedColor
                                    font.family: page.monoFont
                                    font.pixelSize: 11
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: if (page.settings) page.settings.moveCollapsedItem(orderRow.modelData, -1)
                                }
                            }

                            Item {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                opacity: page.settings && orderRow.index < page.settings.collapsedItems.length - 1 ? 1 : 0.3

                                Text {
                                    anchors.centerIn: parent
                                    text: "→"
                                    color: page.mutedColor
                                    font.family: page.monoFont
                                    font.pixelSize: 11
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: if (page.settings) page.settings.moveCollapsedItem(orderRow.modelData, 1)
                                }
                            }
                        }
                    }
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Item spacing"
                value: page.settings ? page.settings.collapsedItemSpacing : 4
                from: 0
                to: 12
                step: 1
                suffix: " px"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.collapsedItemSpacing = value;
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Pill padding"
                value: page.settings ? page.settings.collapsedPadding : 14
                from: 8
                to: 24
                step: 1
                suffix: " px"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.collapsedPadding = value;
                }
            }

            Text {
                text: "DATE"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            Text {
                Layout.fillWidth: true
                text: "Add Date from Clock items above, then choose its format and style."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 8
                wrapMode: Text.Wrap
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 6
                rowSpacing: 6

                Repeater {
                    model: page.settings ? page.settings.dateFormatOptions : []

                    delegate: Rectangle {
                        id: dateChip

                        required property var modelData

                        readonly property bool active: page.settings
                            && page.settings.dateFormat === dateChip.modelData.pattern

                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        radius: 7
                        color: dateChip.active
                            ? page.accentColor
                            : (dateChipHover.hovered
                                ? Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.85)
                                : Qt.rgba(page.surfaceHighColor.r, page.surfaceHighColor.g, page.surfaceHighColor.b, 0.4))

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 7

                            Text {
                                text: "󰃭"
                                color: dateChip.active ? page.onAccentColor : page.accentColor
                                font.family: page.monoFont
                                font.pixelSize: 11
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    Layout.fillWidth: true
                                    text: page.dateExample(dateChip.modelData.pattern)
                                    color: dateChip.active ? page.onAccentColor : page.fgColor
                                    font.family: page.monoFont
                                    font.pixelSize: 9
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: dateChip.modelData.pattern
                                    color: dateChip.active
                                        ? Qt.rgba(page.onAccentColor.r, page.onAccentColor.g, page.onAccentColor.b, 0.65)
                                        : page.mutedColor
                                    font.family: page.monoFont
                                    font.pixelSize: 7
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        HoverHandler {
                            id: dateChipHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (page.settings) page.settings.dateFormat = dateChip.modelData.pattern
                        }
                    }
                }
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Uppercase"
                description: "Render the date in capitals."
                checked: page.settings ? page.settings.dateUppercase : false
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.dateUppercase = !page.settings.dateUppercase
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Accent color"
                description: "Use the accent color instead of muted text."
                checked: page.settings ? page.settings.dateAccent : false
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.dateAccent = !page.settings.dateAccent
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Pill background"
                description: "Give the date its own subtle pill."
                checked: page.settings ? page.settings.datePill : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.datePill = !page.settings.datePill
            }


            Item { implicitHeight: 2 }

            Rectangle {
                Layout.preferredWidth: 150
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
                    onClicked: {
                        if (page.settings)
                            page.settings.resetIsland();
                    }
                }
            }
        }
    }
}
