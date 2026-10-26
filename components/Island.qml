import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: island

    property var mango
    property var stats
    property var volume
    property var bluetooth
    property var network
    property var power
    property var colors
    property var panelWindow
    property bool pinned: false
    property bool pointerHovered: false
    property bool transientActive: false
    property bool wifiMenuOpen: false

    signal pinRequested()

    readonly property string monoFont: "JetBrainsMono Nerd Font Mono"
    readonly property var monitorState: island.mango ? island.mango.monitors[island.mango.focusedMonitor] : null
    readonly property var tags: island.monitorState && island.monitorState.tags ? island.monitorState.tags : []
    readonly property var activeClient: island.monitorState ? island.monitorState.active_client : null
    readonly property var activeTags: island.monitorState && island.monitorState.active_tags ? island.monitorState.active_tags : []
    readonly property var currentTag: {
        if (island.activeTags.length === 0)
            return null;
        const index = Number(island.activeTags[0]) - 1;
        return island.tags.length > index ? island.tags[index] : null;
    }

    readonly property color bgColor: island.colors ? island.colors.surface : "#282828"
    readonly property color surfaceColor: island.colors ? island.colors.surfaceContainer : "#3c3836"
    readonly property color surfaceHighColor: island.colors ? island.colors.surfaceHigh : "#504945"
    readonly property color fgColor: island.colors ? island.colors.fg : "#ebdbb2"
    readonly property color mutedColor: island.colors ? island.colors.fgMuted : "#bdae93"
    readonly property color accentColor: island.colors ? island.colors.accent : "#fabd2f"
    readonly property color onAccentColor: island.colors ? island.colors.onAccent : "#282828"
    readonly property color secondaryColor: island.colors ? island.colors.secondary : "#8ec07c"
    readonly property color tertiaryColor: island.colors ? island.colors.tertiary : "#83a598"
    readonly property color borderColor: island.colors ? island.colors.border : "#928374"
    readonly property color borderMutedColor: island.colors ? island.colors.borderMuted : "#665c54"
    readonly property color errorColor: island.colors ? island.colors.error : "#fb4934"

    readonly property string windowTitle: {
        if (island.activeClient && island.activeClient.title && island.activeClient.title.length > 0)
            return island.activeClient.title;
        if (island.activeClient && island.activeClient.appid && island.activeClient.appid.length > 0)
            return island.activeClient.appid;
        return "Desktop";
    }

    readonly property string workspaceText: island.activeTags.length > 0 ? island.activeTags.join(" · ") : "1"
    readonly property string layoutSymbol: {
        if (island.currentTag && island.currentTag.layout)
            return island.currentTag.layout;
        if (island.monitorState && island.monitorState.layout_symbol)
            return island.monitorState.layout_symbol;
        return "--";
    }

    readonly property var desktopEntry: {
        if (!island.activeClient)
            return null;

        const appid = island.activeClient.appid || "";
        const title = island.activeClient.title || "";

        if (appid.length > 0) {
            const byId = DesktopEntries.byId(appid);
            if (byId)
                return byId;
        }

        if (title.length > 0) {
            const byTitle = DesktopEntries.heuristicLookup(title);
            if (byTitle)
                return byTitle;
        }

        if (appid.length > 0)
            return DesktopEntries.heuristicLookup(appid);

        return null;
    }

    readonly property string appIconSource: {
        if (island.desktopEntry && island.desktopEntry.icon) {
            const entryIcon = island.resolveIcon(island.desktopEntry.icon);
            if (entryIcon.length > 0)
                return entryIcon;
        }

        if (island.activeClient && island.activeClient.appid) {
            const appIcon = island.resolveIcon(island.activeClient.appid);
            if (appIcon.length > 0)
                return appIcon;
        }

        return island.resolveIcon("application-x-executable");
    }

    readonly property string mode: {
        if (island.pinned || island.pointerHovered || island.wifiMenuOpen)
            return "expanded";
        if (island.volume && island.volume.visible)
            return "volume";
        if (island.transientActive)
            return "transient";
        return "collapsed";
    }

    readonly property int targetWidth: {
        if (island.mode === "expanded")
            return 1260;
        if (island.mode === "transient")
            return 380;
        if (island.mode === "volume")
            return 112;
        return 84;
    }

    readonly property int targetHeight: island.mode === "expanded" ? 42 : (island.mode === "transient" ? 36 : 34)
    readonly property string timeText: island.pad(clock.hours) + ":" + island.pad(clock.minutes)

    function pad(value) {
        return value < 10 ? "0" + value : "" + value;
    }

    function resolveIcon(name) {
        if (!name || name.length === 0)
            return "";
        const path = Quickshell.iconPath(name, true);
        return path && path.length > 0 ? path : "";
    }

    function trayIconSource(item) {
        if (!item || !item.icon || item.icon.length === 0)
            return "";

        const icon = item.icon;
        if (icon.indexOf("/") === 0 || icon.indexOf("file:") === 0 || icon.indexOf("image:") === 0 || icon.indexOf("qrc:") === 0 || icon.indexOf("data:") === 0)
            return icon;

        const path = Quickshell.iconPath(icon, true);
        return path && path.length > 0 ? path : icon;
    }

    function showTransient() {
        island.transientActive = true;
        transientTimer.restart();
    }

    function openNotifications() {
        Quickshell.execDetached(["swaync-client", "-t", "-sw"]);
    }

    function toggleWifiMenu() {
        if (!island.network)
            return;

        island.wifiMenuOpen = !island.wifiMenuOpen;
        if (island.wifiMenuOpen)
            island.network.scan();
    }

    function connectWifi(ssid, secure) {
        if (!island.network)
            return;

        island.network.connect(ssid, secure);
        island.wifiMenuOpen = false;
    }

    function powerColor() {
        if (!island.power)
            return island.borderColor;
        if (island.power.profile === "performance")
            return island.errorColor;
        if (island.power.profile === "balanced")
            return island.accentColor;
        if (island.power.profile === "power-saver")
            return island.secondaryColor;
        return island.borderColor;
    }

    onModeChanged: {
        if (island.mode !== "expanded")
            island.wifiMenuOpen = false;
    }

    width: island.targetWidth
    height: island.targetHeight
    radius: 17
    color: Qt.rgba(island.bgColor.r, island.bgColor.g, island.bgColor.b, 0.96)
    border.width: 1
    border.color: island.pinned ? island.accentColor : island.borderMutedColor
    clip: true

    Behavior on width {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: 160
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Connections {
        target: island.mango

        function onWorkspaceChanged(monitor, activeTags) {
            if (monitor === island.mango.focusedMonitor)
                island.showTransient();
        }

        function onMonitorFocused(monitor) {
            island.pointerHovered = false;
            island.transientActive = false;
            transientTimer.stop();
        }
    }

    Timer {
        id: transientTimer
        interval: 2500
        onTriggered: island.transientActive = false
    }

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: island.pointerHovered = hoverHandler.hovered
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: island.pinRequested()
    }

    WheelHandler {
        onWheel: event => {
            if (event.angleDelta.y === 0)
                return;
            island.volume.adjust(event.angleDelta.y > 0 ? 1 : -1);
            event.accepted = true;
        }
    }

    PopupWindow {
        id: wifiPopup

        anchor.window: island.panelWindow
        anchor.item: wifiItem
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
        anchor.margins.bottom: -16
        visible: island.wifiMenuOpen
        grabFocus: true
        implicitWidth: 300
        implicitHeight: 360
        color: "transparent"

        onVisibleChanged: {
            if (!wifiPopup.visible && island.wifiMenuOpen)
                island.wifiMenuOpen = false;
        }

        Rectangle {
            anchors.fill: parent
            radius: 14
            color: Qt.rgba(island.bgColor.r, island.bgColor.g, island.bgColor.b, 0.98)
            border.width: 1
            border.color: island.borderMutedColor
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 7

                    Text {
                        text: "WI-FI"
                        color: island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: island.network
                            ? (island.network.activeSsid.length > 0 ? island.network.activeSsid : (island.network.enabled ? "DISCONNECTED" : "OFF"))
                            : "N/A"
                        color: island.network && island.network.connected ? island.secondaryColor : island.fgColor
                        font.family: island.monoFont
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 22
                        radius: 7
                        color: island.network && island.network.enabled ? island.accentColor : island.surfaceHighColor

                        Text {
                            anchors.centerIn: parent
                            text: island.network && island.network.enabled ? "ON" : "OFF"
                            color: island.network && island.network.enabled ? island.onAccentColor : island.mutedColor
                            font.family: island.monoFont
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (island.network)
                                    island.network.toggle();
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20

                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            color: island.network && island.network.scanning ? island.accentColor : island.mutedColor
                            font.family: island.monoFont
                            font.pixelSize: 13
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (island.network)
                                    island.network.scan();
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: island.borderMutedColor
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "NETWORKS"
                        color: island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: 9
                        font.weight: Font.DemiBold
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: island.network && island.network.scanning
                            ? "SCANNING"
                            : (island.network ? island.network.networks.length + " FOUND" : "0 FOUND")
                        color: island.borderColor
                        font.family: island.monoFont
                        font.pixelSize: 9
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ListView {
                        id: wifiList
                        anchors.fill: parent
                        clip: true
                        spacing: 2
                        model: island.network ? island.network.networks : []

                        delegate: Rectangle {
                            id: wifiRow

                            required property var modelData

                            readonly property bool rowHovered: wifiRowHover.hovered

                            width: ListView.view.width
                            height: 32
                            radius: 7
                            color: wifiRow.rowHovered
                                ? island.surfaceHighColor
                                : (wifiRow.modelData.inUse ? Qt.rgba(island.accentColor.r, island.accentColor.g, island.accentColor.b, 0.16) : "transparent")

                            HoverHandler {
                                id: wifiRowHover
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 7
                                anchors.rightMargin: 7
                                spacing: 6

                                Text {
                                    text: wifiRow.modelData.inUse ? "󰄬" : (wifiRow.modelData.secure ? "󰌾" : "󰤯")
                                    color: wifiRow.modelData.inUse ? island.accentColor : island.mutedColor
                                    font.family: island.monoFont
                                    font.pixelSize: 12
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: wifiRow.modelData.ssid
                                    color: wifiRow.modelData.inUse ? island.accentColor : island.fgColor
                                    font.family: island.monoFont
                                    font.pixelSize: 11
                                    font.weight: wifiRow.modelData.inUse ? Font.DemiBold : Font.Normal
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: wifiRow.modelData.signal + "%"
                                    color: island.mutedColor
                                    font.family: island.monoFont
                                    font.pixelSize: 9
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (wifiRow.modelData.inUse) {
                                        island.wifiMenuOpen = false;
                                    } else {
                                        island.connectWifi(wifiRow.modelData.ssid, wifiRow.modelData.secure);
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !island.network || (!island.network.scanning && island.network.networks.length === 0)
                        text: island.network && island.network.enabled ? "No networks found" : "Wi-Fi is off"
                        color: island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: 10
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: island.borderMutedColor
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 26

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 7

                        Text {
                            text: "󰒓"
                            color: island.mutedColor
                            font.family: island.monoFont
                            font.pixelSize: 12
                        }

                        Text {
                            text: "Edit connections"
                            color: island.fgColor
                            font.family: island.monoFont
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (island.network)
                                island.network.openEditor();
                            island.wifiMenuOpen = false;
                        }
                    }
                }
            }
        }
    }

    Row {
        id: collapsedRow
        anchors.centerIn: parent
        spacing: 0
        visible: island.mode === "collapsed"

        Text {
            text: island.timeText
            color: island.accentColor
            font.family: island.monoFont
            font.pixelSize: 13
            font.weight: Font.DemiBold
            font.letterSpacing: 0.4
        }
    }

    Row {
        id: volumeRow
        anchors.centerIn: parent
        spacing: 6
        visible: island.mode === "volume"

        Text {
            text: "VOL"
            color: island.mutedColor
            font.family: island.monoFont
            font.pixelSize: 10
            font.weight: Font.DemiBold
        }

        Text {
            text: island.volume ? island.volume.levelText : "--"
            color: island.accentColor
            font.family: island.monoFont
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }
    }

    RowLayout {
        id: transientRow
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 9
        visible: island.mode === "transient"

        Text {
            text: "WS"
            color: island.mutedColor
            font.family: island.monoFont
            font.pixelSize: 10
            font.weight: Font.DemiBold
        }

        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 7
            color: island.accentColor

            Text {
                anchors.centerIn: parent
                text: island.workspaceText
                color: island.onAccentColor
                font.family: island.monoFont
                font.pixelSize: 12
                font.weight: Font.Bold
            }
        }

        IconImage {
            visible: island.appIconSource.length > 0
            source: island.appIconSource
            implicitSize: 16
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 80
            text: island.windowTitle
            color: island.fgColor
            font.family: island.monoFont
            font.pixelSize: 12
            font.weight: Font.Medium
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    RowLayout {
        id: expandedRow
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 8
        visible: island.mode === "expanded"

        Text {
            text: island.timeText
            color: island.accentColor
            font.family: island.monoFont
            font.pixelSize: 13
            font.weight: Font.DemiBold
            font.letterSpacing: 0.4
        }

        Row {
            id: trayRow
            spacing: 4
            visible: trayRepeater.count > 0

            Repeater {
                id: trayRepeater
                model: SystemTray.items

                delegate: MouseArea {
                    id: trayItem
                    required property var modelData

                    width: 18
                    height: 18
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: trayItem.modelData.activate()

                    Image {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: island.trayIconSource(trayItem.modelData)
                        sourceSize.width: 16
                        sourceSize.height: 16
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                }
            }
        }

        IslandSeparator {
            visible: trayRepeater.count > 0
            color: island.borderMutedColor
        }

        Row {
            spacing: 4

            Repeater {
                model: 5

                Rectangle {
                    id: tagChip
                    required property int index

                    readonly property var tag: island.tags.length > tagChip.index ? island.tags[tagChip.index] : null
                    readonly property bool active: tagChip.tag ? tagChip.tag.is_active : (tagChip.index + 1 === Number(island.workspaceText))
                    readonly property bool occupied: tagChip.tag ? tagChip.tag.client_count > 0 : false
                    property bool chipHovered: false

                    width: 22
                    height: 22
                    radius: 7
                    color: tagChip.active ? island.accentColor : (tagChip.chipHovered ? island.surfaceHighColor : "transparent")
                    border.width: tagChip.active ? 0 : 1
                    border.color: tagChip.occupied ? island.borderColor : island.borderMutedColor

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: tagChip.index + 1
                        color: tagChip.active ? island.onAccentColor : (tagChip.occupied ? island.fgColor : island.mutedColor)
                        font.family: island.monoFont
                        font.pixelSize: 11
                        font.weight: tagChip.active ? Font.Bold : Font.Medium
                    }

                    Rectangle {
                        width: 3
                        height: 3
                        radius: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 3
                        color: tagChip.occupied && !tagChip.active ? island.accentColor : "transparent"
                    }

                    HoverHandler {
                        onHoveredChanged: tagChip.chipHovered = hovered
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: island.mango.switchTag(tagChip.index + 1)
                    }
                }
            }
        }

        IslandSeparator {
            color: island.borderMutedColor
        }

        IconImage {
            visible: island.appIconSource.length > 0
            source: island.appIconSource
            implicitSize: 18
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 80
            Layout.maximumWidth: 220
            text: island.windowTitle
            color: island.fgColor
            font.family: island.monoFont
            font.pixelSize: 12
            font.weight: Font.Medium
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        IslandSeparator {
            color: island.borderMutedColor
        }

        Row {
            spacing: 4

            Text {
                text: "LAYOUT"
                color: island.mutedColor
                font.family: island.monoFont
                font.pixelSize: 9
                font.weight: Font.DemiBold
            }

            Text {
                text: island.layoutSymbol
                color: island.tertiaryColor
                font.family: island.monoFont
                font.pixelSize: 11
                font.weight: Font.Bold
            }
        }

        IslandSeparator {
            color: island.borderMutedColor
        }

        Row {
            spacing: 4

            Text {
                text: "CPU"
                color: island.mutedColor
                font.family: island.monoFont
                font.pixelSize: 10
                font.weight: Font.DemiBold
            }

            Text {
                text: island.stats ? island.stats.cpuText : "--"
                color: island.fgColor
                font.family: island.monoFont
                font.pixelSize: 12
                font.weight: Font.Medium
            }
        }

        Row {
            spacing: 4

            Text {
                text: "RAM"
                color: island.mutedColor
                font.family: island.monoFont
                font.pixelSize: 10
                font.weight: Font.DemiBold
            }

            Text {
                text: island.stats ? island.stats.memText : "--"
                color: island.fgColor
                font.family: island.monoFont
                font.pixelSize: 12
                font.weight: Font.Medium
            }
        }

        Row {
            spacing: 4

            Text {
                text: "TMP"
                color: island.mutedColor
                font.family: island.monoFont
                font.pixelSize: 10
                font.weight: Font.DemiBold
            }

            Text {
                text: island.stats ? island.stats.tempText : "--"
                color: island.fgColor
                font.family: island.monoFont
                font.pixelSize: 12
                font.weight: Font.Medium
            }
        }

        IslandSeparator {
            color: island.borderMutedColor
        }

        Row {
            spacing: 4

            Text {
                text: "BAT"
                color: island.mutedColor
                font.family: island.monoFont
                font.pixelSize: 9
                font.weight: Font.DemiBold
            }

            Text {
                text: island.stats ? island.stats.batteryIcon : "󰂎"
                color: island.stats && island.stats.batteryPercent >= 0 && island.stats.batteryPercent <= 20 ? island.errorColor : island.secondaryColor
                font.family: island.monoFont
                font.pixelSize: 12
                font.weight: Font.Medium
            }

            Text {
                text: island.stats ? island.stats.batteryText : "--"
                color: island.stats && island.stats.batteryPercent >= 0 && island.stats.batteryPercent <= 20 ? island.errorColor : island.fgColor
                font.family: island.monoFont
                font.pixelSize: 12
                font.weight: Font.Medium
            }
        }

        IslandSeparator {
            color: island.borderMutedColor
        }

        Item {
            id: wifiItem

            Layout.preferredWidth: wifiContent.implicitWidth
            Layout.preferredHeight: 22

            Row {
                id: wifiContent
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    text: island.network ? island.network.icon : "󰤯"
                    color: {
                        if (!island.network || !island.network.enabled)
                            return island.mutedColor;
                        if (island.network.connected)
                            return island.secondaryColor;
                        return island.accentColor;
                    }
                    font.family: island.monoFont
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

                Text {
                    text: island.network ? island.network.label : "--"
                    width: Math.min(implicitWidth, 82)
                    color: island.network && island.network.connected ? island.fgColor : island.mutedColor
                    font.family: island.monoFont
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
            }

            HoverHandler {
                id: wifiHover
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (!island.network)
                        return;
                    if (mouse.button === Qt.RightButton)
                        island.network.toggle();
                    else
                        island.toggleWifiMenu();
                }
            }
        }

        IslandSeparator {
            color: island.borderMutedColor
        }

        Item {
            id: bluetoothItem

            Layout.preferredWidth: bluetoothContent.implicitWidth
            Layout.preferredHeight: 22
            opacity: island.bluetooth && island.bluetooth.busy ? 0.5 : 1

            Row {
                id: bluetoothContent
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    text: island.bluetooth ? island.bluetooth.icon : "󰂲"
                    color: island.bluetooth && island.bluetooth.enabled ? (island.bluetooth.connectedCount > 0 ? island.secondaryColor : island.accentColor) : island.mutedColor
                    font.family: island.monoFont
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

                Text {
                    text: island.bluetooth ? island.bluetooth.label : "--"
                    color: island.bluetooth && island.bluetooth.enabled ? island.fgColor : island.mutedColor
                    font.family: island.monoFont
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                }
            }

            HoverHandler {
                id: bluetoothHover
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (!island.bluetooth)
                        return;
                    if (mouse.button === Qt.RightButton)
                        island.bluetooth.toggle();
                    else
                        island.bluetooth.openManager();
                }
            }
        }

        IslandSeparator {
            color: island.borderMutedColor
        }

        Item {
            id: powerItem

            Layout.preferredWidth: powerContent.implicitWidth
            Layout.preferredHeight: 22
            opacity: island.power && island.power.busy ? 0.5 : 1

            Row {
                id: powerContent
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    text: island.power ? island.power.icon : "󰾅"
                    color: powerHover.hovered ? island.accentColor : island.powerColor()
                    font.family: island.monoFont
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

                Text {
                    text: island.power ? island.power.label : "--"
                    color: powerHover.hovered ? island.accentColor : island.fgColor
                    font.family: island.monoFont
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                }
            }

            HoverHandler {
                id: powerHover
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (island.power)
                        island.power.cycle();
                }
            }
        }

        IslandSeparator {
            color: island.borderMutedColor
        }

        Item {
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22

            HoverHandler {
                id: bellHover
            }

            Text {
                anchors.centerIn: parent
                text: "󰂚"
                color: bellHover.hovered ? island.accentColor : island.fgColor
                font.family: island.monoFont
                font.pixelSize: 14
                font.weight: Font.Medium
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor
                onClicked: island.openNotifications()
            }
        }

        Rectangle {
            visible: island.volume && island.volume.visible
            Layout.preferredWidth: 66
            Layout.preferredHeight: 22
            radius: 7
            color: island.surfaceHighColor

            Row {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: "VOL"
                    color: island.mutedColor
                    font.family: island.monoFont
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                }

                Text {
                    text: island.volume ? island.volume.levelText : "--"
                    color: island.accentColor
                    font.family: island.monoFont
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }
            }
        }
    }

}
