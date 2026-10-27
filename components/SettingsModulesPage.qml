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
                text: "Island Modules"
                color: page.fgColor
                font.family: page.monoFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: "Choose which modules appear in the expanded dashboard. Temporary OSDs are unchanged."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 9
                wrapMode: Text.Wrap
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Workspace tags"
                description: "Show workspace chips in the dashboard header."
                checked: page.settings ? page.settings.showWorkspaceTags : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showWorkspaceTags = !page.settings.showWorkspaceTags
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Window information"
                description: "Show the active window icon and title."
                checked: page.settings ? page.settings.showWindowInfo : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showWindowInfo = !page.settings.showWindowInfo
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "System statistics"
                description: "Show CPU, memory, temperature, and battery."
                checked: page.settings ? page.settings.showSystemStats : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showSystemStats = !page.settings.showSystemStats
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Media card"
                description: "Show the now-playing dashboard card."
                checked: page.settings ? page.settings.showMedia : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showMedia = !page.settings.showMedia
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Volume"
                description: "Show the dashboard volume controls."
                checked: page.settings ? page.settings.showVolume : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showVolume = !page.settings.showVolume
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Brightness"
                description: "Show the dashboard brightness slider."
                checked: page.settings ? page.settings.showBrightness : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showBrightness = !page.settings.showBrightness
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "External brightness"
                description: "Show the DDC/CI brightness slider for external monitors."
                checked: page.settings ? page.settings.showExternalBrightness : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showExternalBrightness = !page.settings.showExternalBrightness
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Notifications"
                description: "Show recent notifications and the notification center entry."
                checked: page.settings ? page.settings.showNotifications : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showNotifications = !page.settings.showNotifications
            }

            Text {
                text: "MODULE DETAILS"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            Text {
                Layout.fillWidth: true
                text: "Fine-tune audio, network, display, system, media, notifications, and Bluetooth behavior."
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 8
                wrapMode: Text.Wrap
            }

            Text {
                text: "AUDIO"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Volume step"
                value: page.settings ? page.settings.volumeStep : 2
                from: 1
                to: 10
                step: 1
                suffix: "%"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.volumeStep = value;
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Volume OSD duration"
                value: page.settings ? page.settings.volumeOsdTimeout : 1500
                from: 800
                to: 4000
                step: 100
                suffix: " ms"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.volumeOsdTimeout = value;
                }
            }

            Text {
                text: "NETWORK"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Wi-Fi network name"
                description: "Show the active network name next to the Wi-Fi icon."
                checked: page.settings ? page.settings.showNetworkName : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showNetworkName = !page.settings.showNetworkName
            }

            Text {
                text: "DISPLAY"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Brightness OSD duration"
                value: page.settings ? page.settings.brightnessOsdTimeout : 1500
                from: 800
                to: 4000
                step: 100
                suffix: " ms"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.brightnessOsdTimeout = value;
                }
            }

            Text {
                text: "CLOCK ITEMS"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            Text {
                Layout.fillWidth: true
                text: "Selected items appear next to the clock in the collapsed Island. Selection order is preserved."
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

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Sync monitor buttons"
                description: "Poll the external monitor for changes made with its physical controls."
                checked: page.settings ? page.settings.ddcSyncEnabled : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.ddcSyncEnabled = !page.settings.ddcSyncEnabled
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "DDC sync interval"
                value: page.settings ? page.settings.ddcSyncInterval : 5000
                from: 2000
                to: 15000
                step: 1000
                suffix: " ms"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.ddcSyncInterval = value;
                }
            }

            Text {
                text: "SYSTEM STATS"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "CPU"
                description: "Show CPU usage in the dashboard stats row."
                checked: page.settings ? page.settings.showCpuStat : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showCpuStat = !page.settings.showCpuStat
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Memory"
                description: "Show memory usage in the dashboard stats row."
                checked: page.settings ? page.settings.showRamStat : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showRamStat = !page.settings.showRamStat
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Temperature"
                description: "Show temperature in the dashboard stats row."
                checked: page.settings ? page.settings.showTempStat : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showTempStat = !page.settings.showTempStat
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Battery"
                description: "Show battery state in the dashboard stats row."
                checked: page.settings ? page.settings.showBatteryStat : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showBatteryStat = !page.settings.showBatteryStat
            }

            Text {
                text: "MEDIA"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Album artwork"
                description: "Show cover art in the dashboard media card and OSD."
                checked: page.settings ? page.settings.showMediaArtwork : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showMediaArtwork = !page.settings.showMediaArtwork
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Playback progress"
                description: "Show the seek position and progress bar."
                checked: page.settings ? page.settings.showMediaProgress : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showMediaProgress = !page.settings.showMediaProgress
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Media OSD duration"
                value: page.settings ? page.settings.mediaOsdTimeout : 4000
                from: 1000
                to: 10000
                step: 100
                suffix: " ms"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.mediaOsdTimeout = value;
                }
            }

            Text {
                text: "NOTIFICATIONS"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Notification images"
                description: "Show image attachments in notification cards."
                checked: page.settings ? page.settings.showNotificationImages : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showNotificationImages = !page.settings.showNotificationImages
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Notification OSD duration"
                value: page.settings ? page.settings.notificationOsdTimeout : 6000
                from: 2200
                to: 12000
                step: 100
                suffix: " ms"
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.notificationOsdTimeout = value;
                }
            }

            SettingsSlider {
                Layout.fillWidth: true
                label: "Notification history limit"
                value: page.settings ? page.settings.notificationHistoryLimit : 50
                from: 10
                to: 100
                step: 5
                suffix: ""
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                surfaceHighColor: page.surfaceHighColor
                onMoved: value => {
                    if (page.settings)
                        page.settings.notificationHistoryLimit = value;
                }
            }

            Text {
                text: "BLUETOOTH"
                color: page.mutedColor
                font.family: page.monoFont
                font.pixelSize: 7
                font.weight: Font.DemiBold
                font.letterSpacing: 0.5
            }

            SettingsToggleRow {
                Layout.fillWidth: true
                label: "Status text"
                description: "Show the Bluetooth status label next to the icon."
                checked: page.settings ? page.settings.showBluetoothStatus : true
                monoFont: page.monoFont
                fgColor: page.fgColor
                mutedColor: page.mutedColor
                accentColor: page.accentColor
                onAccentColor: page.onAccentColor
                surfaceHighColor: page.surfaceHighColor
                onToggled: if (page.settings) page.settings.showBluetoothStatus = !page.settings.showBluetoothStatus
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
                    onClicked: {
                        if (page.settings) {
                            page.settings.resetModules();
                            page.settings.resetCollapsedItems();
                        }
                    }
                }
            }
        }
    }
}
