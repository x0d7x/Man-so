import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: island

    property var mango
    property var stats
    property var volume
    property var brightness
    property var ddcBrightness
    property var notifications
    property var media
    property var diagnostics
    property var settings
    property var privacy
    property var keyboardLayout
    property var bluetooth
    property var network
    property var power
    property var colors
    property var panelWindow
    property bool pinned: false
    property bool pointerHovered: false
    property bool transientActive: false
    property bool layoutOsdActive: false
    property string layoutOsdText: ""
    property bool suppressHoverKeyboard: false
    property bool wifiMenuOpen: false
    property bool wifiPasswordOpen: false
    property bool bluetoothMenuOpen: false
    property bool settingsOpen: false
    property string bluetoothInput: ""
    property var wifiSelectedNetwork: null
    property string wifiPasswordText: ""
    property string wifiPasswordError: ""

    signal pinRequested()

    readonly property string monoFont: island.settings && island.settings.fontFamily.length > 0
        ? island.settings.fontFamily
        : "JetBrainsMono Nerd Font Mono"
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

    readonly property bool hoverExpansionEnabled: island.settings ? island.settings.expansionMode === "hover" : true
    readonly property int animationDuration: island.settings ? island.settings.animationDuration : 220
    readonly property int backgroundOpacity: island.settings ? island.settings.backgroundOpacity : 100
    readonly property int cornerRadius: island.settings ? island.settings.cornerRadius : 17
    readonly property bool borderVisible: island.settings ? island.settings.borderVisible : true
    readonly property int borderThickness: island.settings ? island.settings.borderWidth : 1
    readonly property real fontScale: island.settings ? island.settings.fontSize / 11 : 1
    readonly property real uiScale: island.settings ? island.settings.uiScale / 100 : 1
    readonly property bool showWorkspaceTags: island.settings ? island.settings.showWorkspaceTags : true
    readonly property bool showWindowInfo: island.settings ? island.settings.showWindowInfo : true
    readonly property bool showSystemStats: island.settings ? island.settings.showSystemStats : true
    readonly property bool showMedia: island.settings ? island.settings.showMedia : true
    readonly property bool showVolume: island.settings ? island.settings.showVolume : true
    readonly property bool showNetworkName: island.settings ? island.settings.showNetworkName : true
    readonly property bool showBrightness: island.settings ? island.settings.showBrightness : true
    readonly property bool showExternalBrightness: island.settings ? island.settings.showExternalBrightness : true
    readonly property bool showNotifications: island.settings ? island.settings.showNotifications : true
    readonly property bool showCpuStat: island.settings ? island.settings.showCpuStat : true
    readonly property bool showRamStat: island.settings ? island.settings.showRamStat : true
    readonly property bool showTempStat: island.settings ? island.settings.showTempStat : true
    readonly property bool showBatteryStat: island.settings ? island.settings.showBatteryStat : true
    readonly property bool hasVisibleStats: island.showCpuStat || island.showRamStat
        || island.showTempStat || island.showBatteryStat
    readonly property bool showMediaArtwork: island.settings ? island.settings.showMediaArtwork : true
    readonly property bool showMediaProgress: island.settings ? island.settings.showMediaProgress : true
    readonly property bool showNotificationImages: island.settings ? island.settings.showNotificationImages : true
    readonly property bool showBluetoothStatus: island.settings ? island.settings.showBluetoothStatus : true
    readonly property bool privacyShowCollapsed: island.settings ? island.settings.privacyShowCollapsed : true
    readonly property string workspaceVisibility: island.settings ? island.settings.workspaceVisibility : "all"
    readonly property bool showOccupiedIndicator: island.settings ? island.settings.showOccupiedIndicator : true
    readonly property bool includeUrgentWorkspaces: island.settings ? island.settings.includeUrgentWorkspaces : true
    readonly property var collapsedItems: island.settings ? island.settings.collapsedItems : ["time"]
    readonly property bool collapsedHasNotificationItem: island.collapsedItems.indexOf("notifications") >= 0
    readonly property bool showCollapsedUnreadBell: island.showNotifications
        && !island.collapsedHasNotificationItem
        && island.notifications
        && island.notifications.unreadCount > 0
    readonly property int collapsedItemSpacing: island.settings ? island.settings.collapsedItemSpacing : 4
    readonly property int collapsedPadding: island.settings ? island.settings.collapsedPadding : 14
    readonly property var visibleTags: {
        const list = island.tags;
        if (island.workspaceVisibility === "active") {
            return list.filter(tag => tag && (tag.is_active || (island.includeUrgentWorkspaces && tag.is_urgent)));
        }
        if (island.workspaceVisibility === "occupied") {
            return list.filter(tag => tag && (tag.client_count > 0 || tag.is_active
                || (island.includeUrgentWorkspaces && tag.is_urgent)));
        }
        return list;
    }
    readonly property int batteryWarningThreshold: island.settings ? island.settings.batteryWarningThreshold : 20
    readonly property int batteryCriticalThreshold: island.settings ? island.settings.batteryCriticalThreshold : 10
    readonly property bool batteryCharging: island.stats
        && (island.stats.batteryStatus === "Charging" || island.stats.batteryStatus === "Full")
    readonly property bool batteryCriticalActive: island.stats
        && island.stats.batteryPercent >= 0
        && island.stats.batteryPercent <= island.batteryCriticalThreshold
        && !island.batteryCharging
    readonly property bool batteryWarningActive: island.stats
        && island.stats.batteryPercent >= 0
        && island.stats.batteryPercent <= island.batteryWarningThreshold
        && !island.batteryCharging

    readonly property bool needsKeyboard: island.settingsOpen
        || island.wifiMenuOpen || island.bluetoothMenuOpen
        || (island.notifications && island.notifications.centerOpen)
        || (island.pointerHovered && island.hoverExpansionEnabled && !island.suppressHoverKeyboard)

    readonly property string mode: {
        if (island.settingsOpen)
            return "settings";
        if (island.wifiMenuOpen)
            return "wifi";
        if (island.bluetoothMenuOpen)
            return "bluetooth";
        if (island.notifications && island.notifications.visible && island.notifications.active)
            return "notification";
        if (island.layoutOsdActive)
            return "layout";
        if (island.pinned)
            return "expanded";
        if (island.volume && island.volume.visible)
            return "volume";
        if (island.brightness && island.brightness.visible)
            return "brightness";
        if (island.keyboardLayout && island.keyboardLayout.visible)
            return "keyboardLayout";
        if (island.media && island.media.visible)
            return "media";
        if ((island.pointerHovered && island.hoverExpansionEnabled) || island.wifiMenuOpen
            || island.bluetoothMenuOpen || (island.notifications && island.notifications.centerOpen))
            return "expanded";
        if (island.transientActive)
            return "transient";
        return "collapsed";
    }

    readonly property int targetWidth: {
        if (island.mode === "settings")
            return 560;
        if (island.mode === "wifi")
            return 380;
        if (island.mode === "bluetooth")
            return 380;
        if (island.mode === "notification")
            return 460;
        if (island.mode === "media")
            return 460;
        if (island.mode === "expanded")
            return 420;
        if (island.mode === "layout")
            return 260;
        if (island.mode === "transient")
            return 380;
        if (island.mode === "volume")
            return 250;
        if (island.mode === "brightness")
            return 250;
        if (island.mode === "keyboardLayout")
            return 300;
        if (island.mode === "collapsed")
            return Math.max(84, Math.round(collapsedRow.implicitWidth + island.collapsedPadding * 2));
        return 84;
    }

    readonly property int targetHeight: {
        if (island.mode === "settings")
            return 420;
        if (island.mode === "wifi")
            return 420;
        if (island.mode === "bluetooth")
            return 420;
        if (island.mode === "notification")
            return 104;
        if (island.mode === "media")
            return 104;
        if (island.mode === "expanded")
            return 420;
        if (island.mode === "transient")
            return 36;
        return 34;
    }
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

    function showLayoutOsd(layout) {
        if (!layout || layout.length === 0)
            return;
        island.layoutOsdText = layout;
        island.layoutOsdActive = true;
        layoutOsdTimer.restart();
    }

    function openSettings() {
        if (island.settingsOpen)
            return;
        if (island.wifiMenuOpen)
            island.closeWifiMenu();
        if (island.bluetoothMenuOpen)
            island.closeBluetoothMenu();
        if (island.notifications && island.notifications.centerOpen)
            island.closeNotificationCenter();
        island.settingsOpen = true;
    }

    function closeSettings() {
        if (!island.settingsOpen)
            return;
        if (island.settings)
            island.settings.flush();
        island.settingsOpen = false;
        island.releaseHoverKeyboard();
    }

    function toggleSettings() {
        if (island.settingsOpen)
            island.closeSettings();
        else
            island.openSettings();
    }

    function closeNotificationCenter() {
        if (!island.notifications)
            return;
        notificationCenterDelay.stop();
        notificationCenterPopup.visible = false;
        island.notifications.closeCenter();
        island.releaseHoverKeyboard();
    }

    function toggleNotificationCenter() {
        if (!island.notifications)
            return;

        if (island.notifications.centerOpen) {
            island.closeNotificationCenter();
            return;
        }

        if (island.wifiMenuOpen)
            island.closeWifiMenu();
        if (island.bluetoothMenuOpen)
            island.closeBluetoothMenu();

        island.notifications.openCenter();
        notificationCenterDelay.restart();
    }

    function releaseHoverKeyboard() {
        if (!island.pointerHovered) {
            island.suppressHoverKeyboard = false;
            return;
        }

        island.suppressHoverKeyboard = true;
        hoverKeyboardReleaseTimer.restart();
    }

    function closeWifiMenu() {
        island.wifiMenuOpen = false;
        island.wifiPasswordOpen = false;
        island.wifiSelectedNetwork = null;
        island.wifiPasswordText = "";
        island.wifiPasswordError = "";
        if (island.network)
            island.network.setScanning(false);
        island.releaseHoverKeyboard();
    }

    function toggleWifiMenu() {
        if (!island.network)
            return;

        if (island.wifiMenuOpen) {
            island.closeWifiMenu();
            return;
        }

        if (island.bluetoothMenuOpen)
            island.closeBluetoothMenu();

        island.wifiMenuOpen = true;
        island.network.clearError();
        island.network.setScanning(true);
    }

    function selectWifi(network) {
        if (!network || !island.network)
            return;
        if (network.connected) {
            island.closeWifiMenu();
            return;
        }

        island.network.clearError();
        island.wifiPasswordError = "";

        if (island.network.isEnterprise(network)) {
            island.wifiPasswordError = "Enterprise Wi-Fi needs the connection editor";
            return;
        }

        if (island.network.needsPassword(network)) {
            island.wifiSelectedNetwork = network;
            island.wifiPasswordText = "";
            island.wifiPasswordOpen = true;
            return;
        }

        island.network.connect(network);
    }

    function cancelWifiPassword() {
        island.wifiPasswordOpen = false;
        island.wifiSelectedNetwork = null;
        island.wifiPasswordText = "";
        island.wifiPasswordError = "";
        if (island.network)
            island.network.clearError();
    }

    function submitWifiPassword() {
        if (!island.wifiSelectedNetwork || !island.network)
            return;

        if (island.wifiPasswordText.length === 0) {
            island.wifiPasswordError = "Password is required";
            return;
        }

        island.network.connectWithPassword(island.wifiSelectedNetwork, island.wifiPasswordText);
        island.wifiPasswordText = "";
        island.wifiPasswordOpen = false;
        island.wifiSelectedNetwork = null;
        island.wifiPasswordError = "";
    }

    function toggleBluetoothMenu() {
        if (!island.bluetooth)
            return;

        if (island.bluetoothMenuOpen) {
            island.closeBluetoothMenu();
            return;
        }

        if (island.wifiMenuOpen)
            island.closeWifiMenu();

        island.bluetoothMenuOpen = true;
        island.bluetooth.clearPrompt();
        island.bluetooth.startDiscovery();
    }

    function closeBluetoothMenu() {
        island.bluetoothMenuOpen = false;
        island.bluetoothInput = "";
        if (island.bluetooth) {
            island.bluetooth.cancelPairing();
            island.bluetooth.stopDiscovery();
        }
        island.releaseHoverKeyboard();
    }

    function submitBluetoothPasskey() {
        if (!island.bluetooth)
            return;
        island.bluetooth.submitPasskey(island.bluetoothInput);
        island.bluetoothInput = "";
    }

    function cancelBluetoothPrompt() {
        if (!island.bluetooth)
            return;
        island.bluetooth.rejectPrompt();
        island.bluetoothInput = "";
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

    onPointerHoveredChanged: {
        if (island.pointerHovered && island.mode === "media" && island.media)
            island.media.show();
    }

    onModeChanged: {
        if (island.mode !== "expanded" && island.mode !== "wifi" && island.mode !== "bluetooth") {
            if (island.wifiMenuOpen)
                island.closeWifiMenu();
            if (island.bluetoothMenuOpen)
                island.closeBluetoothMenu();
            if (island.notifications && island.notifications.centerOpen)
                island.closeNotificationCenter();
        }
    }

    Connections {
        target: island.bluetooth

        function onPromptModeChanged() {
            island.bluetoothInput = "";
            if (island.bluetooth && island.bluetooth.promptNeedsInput) {
                Qt.callLater(() => bluetoothInput.forceActiveFocus());
            } else if (island.bluetooth && island.bluetooth.promptActive) {
                Qt.callLater(() => bluetoothPromptOverlay.forceActiveFocus());
            } else if (island.bluetoothMenuOpen) {
                Qt.callLater(() => bluetoothEscapeFocus.forceActiveFocus());
            }
        }
    }

    Timer {
        id: hoverKeyboardReleaseTimer
        interval: 100
        onTriggered: island.suppressHoverKeyboard = false
    }

    Timer {
        id: notificationCenterDelay
        interval: 80
        onTriggered: {
            if (island.notifications && island.notifications.centerOpen) {
                notificationCenterPopup.visible = true;
                Qt.callLater(() => notificationCenterEscapeFocus.forceActiveFocus());
            }
        }
    }

    onWifiPasswordOpenChanged: {
        if (island.wifiPasswordOpen) {
            Qt.callLater(() => passwordInput.forceActiveFocus());
        } else if (island.wifiMenuOpen) {
            Qt.callLater(() => wifiEscapeFocus.forceActiveFocus());
        }
    }

    width: island.targetWidth
    height: island.targetHeight
    radius: island.cornerRadius
    transform: Scale {
        origin.x: island.width / 2
        origin.y: 0
        xScale: island.uiScale
        yScale: island.uiScale
    }
    color: Qt.rgba(island.bgColor.r, island.bgColor.g, island.bgColor.b, island.backgroundOpacity / 100)
    border.width: island.mode === "notification" || island.mode === "media"
        ? 0
        : (island.borderVisible ? island.borderThickness : 0)
    border.color: island.pinned ? island.accentColor : island.borderMutedColor
    clip: true

    Behavior on width {
        NumberAnimation {
            duration: island.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: Math.round(island.animationDuration * 0.82)
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

        function onLayoutChanged(monitor, layout) {
            if (monitor === island.mango.focusedMonitor)
                island.showLayoutOsd(layout);
        }

        function onMonitorFocused(monitor) {
            island.pointerHovered = false;
            island.transientActive = false;
            island.layoutOsdActive = false;
            transientTimer.stop();
            layoutOsdTimer.stop();
        }
    }

    Timer {
        id: transientTimer
        interval: 2500
        onTriggered: island.transientActive = false
    }

    Timer {
        id: layoutOsdTimer
        interval: 1500
        onTriggered: island.layoutOsdActive = false
    }

    HoverHandler {
        id: hoverHandler

        onHoveredChanged: {
            island.pointerHovered = hoverHandler.hovered;
            if (!hoverHandler.hovered) {
                hoverKeyboardReleaseTimer.stop();
                island.suppressHoverKeyboard = false;
            }
        }
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

    FocusScope {
        id: wifiPanel

        anchors.fill: parent
        visible: island.mode === "wifi"
        focus: visible

        onVisibleChanged: {
            if (visible && !island.wifiPasswordOpen)
                Qt.callLater(() => wifiEscapeFocus.forceActiveFocus());
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {}
        }

        Rectangle {
            id: wifiCard

            anchors.fill: parent
            radius: 0
            color: "transparent"
            border.width: 0
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
                        font.pixelSize: Math.round(10 * island.fontScale)
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: island.network
                            ? (island.network.activeSsid.length > 0 ? island.network.activeSsid : (island.network.enabled ? "DISCONNECTED" : "OFF"))
                            : "N/A"
                        color: island.network && island.network.connected ? island.secondaryColor : island.fgColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(11 * island.fontScale)
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
                            font.pixelSize: Math.round(9 * island.fontScale)
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
                            font.pixelSize: Math.round(13 * island.fontScale)
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (island.network)
                                    island.network.setScanning(true);
                            }
                        }
                    }
                    Item {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: wifiCloseHover.hovered ? island.errorColor : island.mutedColor
                            font.family: island.monoFont
                            font.pixelSize: Math.round(13 * island.fontScale)
                        }

                        HoverHandler {
                            id: wifiCloseHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: island.closeWifiMenu()
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
                        font.pixelSize: Math.round(9 * island.fontScale)
                        font.weight: Font.DemiBold
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: island.network
                            ? island.network.networks.length + " FOUND"
                            : "0 FOUND"
                        color: island.borderColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(9 * island.fontScale)
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
                                : (wifiRow.modelData.connected ? Qt.rgba(island.accentColor.r, island.accentColor.g, island.accentColor.b, 0.16) : "transparent")

                            HoverHandler {
                                id: wifiRowHover
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 7
                                anchors.rightMargin: 7
                                spacing: 6

                                Text {
                                    text: wifiRow.modelData.connected
                                        ? "󰄬"
                                        : (island.network && !island.network.isOpen(wifiRow.modelData) ? "󰌾" : "󰤯")
                                    color: wifiRow.modelData.connected ? island.accentColor : island.mutedColor
                                    font.family: island.monoFont
                                    font.pixelSize: Math.round(12 * island.fontScale)
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: wifiRow.modelData.name
                                    color: wifiRow.modelData.connected ? island.accentColor : island.fgColor
                                    font.family: island.monoFont
                                    font.pixelSize: Math.round(11 * island.fontScale)
                                    font.weight: wifiRow.modelData.connected ? Font.DemiBold : Font.Normal
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: Math.round(wifiRow.modelData.signalStrength * 100) + "%"
                                    color: island.mutedColor
                                    font.family: island.monoFont
                                    font.pixelSize: Math.round(9 * island.fontScale)
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: island.selectWifi(wifiRow.modelData)
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !island.network || island.network.networks.length === 0
                        text: {
                            if (!island.network || !island.network.enabled)
                                return "Wi-Fi is off";
                            if (island.network.scanning)
                                return "Scanning…";
                            return "No networks found";
                        }
                        color: island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(10 * island.fontScale)
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: island.network && island.network.lastError.length > 0
                    text: island.network ? island.network.lastError : ""
                    color: island.errorColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(9 * island.fontScale)
                    wrapMode: Text.WordWrap
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
                            font.pixelSize: Math.round(12 * island.fontScale)
                        }

                        Text {
                            text: "Edit connections"
                            color: island.fgColor
                            font.family: island.monoFont
                            font.pixelSize: Math.round(10 * island.fontScale)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (island.network)
                                island.network.openEditor();
                            island.closeWifiMenu();
                        }
                    }
                }
            }

            FocusScope {
                id: wifiEscapeFocus

                anchors.fill: parent
                focus: island.wifiMenuOpen && !island.wifiPasswordOpen
                Keys.onEscapePressed: island.closeWifiMenu()
            }

            Rectangle {
                id: wifiPasswordOverlay

                anchors.fill: parent
                visible: island.wifiPasswordOpen
                focus: island.wifiPasswordOpen
                Keys.onEscapePressed: island.cancelWifiPassword()
                z: 10
                radius: 14
                color: Qt.rgba(island.bgColor.r, island.bgColor.g, island.bgColor.b, 0.99)
                border.width: 1
                border.color: island.borderMutedColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Text {
                        text: "JOIN NETWORK"
                        color: island.accentColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(10 * island.fontScale)
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: island.wifiSelectedNetwork ? island.wifiSelectedNetwork.name : ""
                        color: island.fgColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(14 * island.fontScale)
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        text: "Wi-Fi password"
                        color: island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(10 * island.fontScale)
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius: 8
                        color: island.surfaceHighColor
                        border.width: 1
                        border.color: passwordInput.activeFocus ? island.accentColor : island.borderMutedColor

                        TextInput {
                            id: passwordInput

                            anchors.fill: parent
                            anchors.leftMargin: 9
                            anchors.rightMargin: 9
                            verticalAlignment: TextInput.AlignVCenter
                            text: island.wifiPasswordText
                            color: island.fgColor
                            selectionColor: island.accentColor
                            selectedTextColor: island.onAccentColor
                            font.family: island.monoFont
                            font.pixelSize: Math.round(12 * island.fontScale)
                            echoMode: TextInput.Password
                            passwordCharacter: "●"
                            focus: island.wifiPasswordOpen
                            onAccepted: island.submitWifiPassword()
                            onTextChanged: {
                                if (island.wifiPasswordText !== text)
                                    island.wifiPasswordText = text;
                                if (island.wifiPasswordError.length > 0)
                                    island.wifiPasswordError = "";
                            }
                            Keys.onEscapePressed: island.cancelWifiPassword()
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: island.wifiPasswordError.length > 0 || (island.network && island.network.lastError.length > 0)
                        text: island.wifiPasswordError.length > 0
                            ? island.wifiPasswordError
                            : (island.network ? island.network.lastError : "")
                        color: island.errorColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(9 * island.fontScale)
                        wrapMode: Text.WordWrap
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30
                            radius: 8
                            color: island.surfaceHighColor

                            Text {
                                anchors.centerIn: parent
                                text: "CANCEL"
                                color: island.fgColor
                                font.family: island.monoFont
                                font.pixelSize: Math.round(9 * island.fontScale)
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: island.cancelWifiPassword()
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 88
                            Layout.preferredHeight: 30
                            radius: 8
                            color: island.wifiPasswordText.length > 0 ? island.accentColor : island.surfaceHighColor

                            Text {
                                anchors.centerIn: parent
                                text: "CONNECT"
                                color: island.wifiPasswordText.length > 0 ? island.onAccentColor : island.mutedColor
                                font.family: island.monoFont
                                font.pixelSize: Math.round(9 * island.fontScale)
                                font.weight: Font.Bold
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: island.submitWifiPassword()
                            }
                        }
                    }
                }
            }
        }
    }

    FocusScope {
        id: bluetoothPanel

        anchors.fill: parent
        visible: island.mode === "bluetooth"
        focus: visible

        onVisibleChanged: {
            if (visible && !(island.bluetooth && island.bluetooth.promptActive))
                Qt.callLater(() => bluetoothEscapeFocus.forceActiveFocus());
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {}
        }

        Rectangle {
            id: bluetoothCard

            anchors.fill: parent
            radius: 0
            color: "transparent"
            border.width: 0
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 7

                    Text {
                        text: "BLUETOOTH"
                        color: island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(10 * island.fontScale)
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: island.bluetooth ? island.bluetooth.label : "N/A"
                        color: island.bluetooth && island.bluetooth.enabled
                            ? (island.bluetooth.connectedCount > 0 ? island.secondaryColor : island.accentColor)
                            : island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(11 * island.fontScale)
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 22
                        radius: 7
                        color: island.bluetooth && island.bluetooth.enabled ? island.accentColor : island.surfaceHighColor
                        opacity: island.bluetooth && island.bluetooth.busy ? 0.5 : 1

                        Text {
                            anchors.centerIn: parent
                            text: island.bluetooth && island.bluetooth.enabled ? "ON" : "OFF"
                            color: island.bluetooth && island.bluetooth.enabled ? island.onAccentColor : island.mutedColor
                            font.family: island.monoFont
                            font.pixelSize: Math.round(9 * island.fontScale)
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (island.bluetooth)
                                    island.bluetooth.toggle();
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20

                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            color: island.bluetooth && island.bluetooth.discovering ? island.accentColor : island.mutedColor
                            font.family: island.monoFont
                            font.pixelSize: Math.round(13 * island.fontScale)
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (island.bluetooth)
                                    island.bluetooth.startDiscovery();
                            }
                        }
                    }
                    Item {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: btCloseHover.hovered ? island.errorColor : island.mutedColor
                            font.family: island.monoFont
                            font.pixelSize: Math.round(13 * island.fontScale)
                        }

                        HoverHandler {
                            id: btCloseHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: island.closeBluetoothMenu()
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
                    visible: island.bluetooth && island.bluetooth.enabled

                    Text {
                        text: "DEVICES"
                        color: island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(9 * island.fontScale)
                        font.weight: Font.DemiBold
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: island.bluetooth ? island.bluetooth.devices.length + " FOUND" : "0 FOUND"
                        color: island.borderColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(9 * island.fontScale)
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: island.bluetooth && island.bluetooth.enabled

                    ListView {
                        anchors.fill: parent
                        clip: true
                        spacing: 2
                        model: island.bluetooth ? island.bluetooth.devices : []

                        delegate: Rectangle {
                            id: bluetoothRow

                            required property var modelData

                            readonly property bool rowHovered: bluetoothRowHover.hovered

                            width: ListView.view.width
                            height: 40
                            radius: 7
                            color: bluetoothRow.rowHovered
                                ? island.surfaceHighColor
                                : (bluetoothRow.modelData.connected ? Qt.rgba(island.accentColor.r, island.accentColor.g, island.accentColor.b, 0.16) : "transparent")

                            HoverHandler {
                                id: bluetoothRowHover
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 7
                                anchors.rightMargin: 7
                                spacing: 7

                                Text {
                                    text: bluetoothRow.modelData.connected
                                        ? "󰂱"
                                        : (bluetoothRow.modelData.paired ? "󰂯" : "󰂰")
                                    color: bluetoothRow.modelData.connected
                                        ? island.secondaryColor
                                        : (bluetoothRow.modelData.paired ? island.accentColor : island.mutedColor)
                                    font.family: island.monoFont
                                    font.pixelSize: Math.round(14 * island.fontScale)
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0

                                    Text {
                                        Layout.fillWidth: true
                                        text: bluetoothRow.modelData.name
                                            ? bluetoothRow.modelData.name
                                            : bluetoothRow.modelData.address
                                        color: bluetoothRow.modelData.connected ? island.accentColor : island.fgColor
                                        font.family: island.monoFont
                                        font.pixelSize: Math.round(11 * island.fontScale)
                                        font.weight: bluetoothRow.modelData.connected ? Font.DemiBold : Font.Medium
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: bluetoothRow.modelData.pairing
                                            ? "PAIRING"
                                            : (bluetoothRow.modelData.connected
                                                ? "CONNECTED"
                                                : (bluetoothRow.modelData.paired ? "PAIRED" : "AVAILABLE"))
                                        color: bluetoothRow.modelData.pairing ? island.accentColor : island.mutedColor
                                        font.family: island.monoFont
                                        font.pixelSize: Math.round(8 * island.fontScale)
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                }

                                Text {
                                    visible: bluetoothRow.modelData.batteryAvailable
                                    text: bluetoothRow.modelData.batteryAvailable
                                        ? Math.round(bluetoothRow.modelData.battery * 100) + "%"
                                        : ""
                                    color: island.mutedColor
                                    font.family: island.monoFont
                                    font.pixelSize: Math.round(9 * island.fontScale)
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: island.bluetooth.activate(bluetoothRow.modelData)
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !island.bluetooth || island.bluetooth.devices.length === 0
                        text: island.bluetooth && island.bluetooth.discovering ? "Scanning…" : "No devices found"
                        color: island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(10 * island.fontScale)
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8
                    visible: !island.bluetooth || !island.bluetooth.enabled

                    Item {
                        Layout.fillHeight: true
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Bluetooth is off"
                        color: island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(11 * island.fontScale)
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 96
                        Layout.preferredHeight: 30
                        radius: 8
                        color: island.accentColor

                        Text {
                            anchors.centerIn: parent
                            text: "TURN ON"
                            color: island.onAccentColor
                            font.family: island.monoFont
                            font.pixelSize: Math.round(9 * island.fontScale)
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (island.bluetooth)
                                    island.bluetooth.setEnabled(true);
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: island.bluetooth && island.bluetooth.lastError.length > 0
                    text: island.bluetooth ? island.bluetooth.lastError : ""
                    color: island.errorColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(9 * island.fontScale)
                    wrapMode: Text.WordWrap
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
                            font.pixelSize: Math.round(12 * island.fontScale)
                        }

                        Text {
                            text: "Open Bluetooth manager"
                            color: island.fgColor
                            font.family: island.monoFont
                            font.pixelSize: Math.round(10 * island.fontScale)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (island.bluetooth)
                                island.bluetooth.openManager();
                            island.closeBluetoothMenu();
                        }
                    }
                }
            }

            FocusScope {
                id: bluetoothEscapeFocus

                anchors.fill: parent
                focus: island.bluetoothMenuOpen && !(island.bluetooth && island.bluetooth.promptActive)
                Keys.onEscapePressed: island.closeBluetoothMenu()
            }

            Rectangle {
                id: bluetoothPromptOverlay

                anchors.fill: parent
                visible: island.bluetooth && island.bluetooth.promptActive
                focus: island.bluetooth && island.bluetooth.promptActive
                Keys.onEscapePressed: island.cancelBluetoothPrompt()
                z: 10
                radius: 14
                color: Qt.rgba(island.bgColor.r, island.bgColor.g, island.bgColor.b, 0.99)
                border.width: 1
                border.color: island.borderMutedColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Text {
                        text: "BLUETOOTH PAIRING"
                        color: island.accentColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(10 * island.fontScale)
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: island.bluetooth ? island.bluetooth.promptDeviceName : ""
                        color: island.fgColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(14 * island.fontScale)
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: island.bluetooth ? island.bluetooth.promptMessage : ""
                        color: island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(10 * island.fontScale)
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: island.bluetooth && island.bluetooth.promptPasskey.length > 0
                        text: island.bluetooth ? island.bluetooth.promptPasskey : ""
                        color: island.accentColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(26 * island.fontScale)
                        font.weight: Font.Bold
                        font.letterSpacing: 3
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        visible: island.bluetooth && island.bluetooth.promptNeedsInput
                        radius: 8
                        color: island.surfaceHighColor
                        border.width: 1
                        border.color: bluetoothInput.activeFocus ? island.accentColor : island.borderMutedColor

                        TextInput {
                            id: bluetoothInput

                            anchors.fill: parent
                            anchors.leftMargin: 9
                            anchors.rightMargin: 9
                            verticalAlignment: TextInput.AlignVCenter
                            text: island.bluetoothInput
                            color: island.fgColor
                            selectionColor: island.accentColor
                            selectedTextColor: island.onAccentColor
                            font.family: island.monoFont
                            font.pixelSize: Math.round(12 * island.fontScale)
                            inputMethodHints: Qt.ImhDigitsOnly
                            focus: island.bluetooth && island.bluetooth.promptNeedsInput
                            onAccepted: island.submitBluetoothPasskey()
                            onTextChanged: {
                                if (island.bluetoothInput !== text)
                                    island.bluetoothInput = text;
                            }
                            Keys.onEscapePressed: island.cancelBluetoothPrompt()
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: island.bluetooth && island.bluetooth.lastError.length > 0
                        text: island.bluetooth ? island.bluetooth.lastError : ""
                        color: island.errorColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(9 * island.fontScale)
                        wrapMode: Text.WordWrap
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30
                            radius: 8
                            color: island.surfaceHighColor
                            visible: island.bluetooth && island.bluetooth.promptMode !== "display"

                            Text {
                                anchors.centerIn: parent
                                text: "CANCEL"
                                color: island.fgColor
                                font.family: island.monoFont
                                font.pixelSize: Math.round(9 * island.fontScale)
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: island.cancelBluetoothPrompt()
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 92
                            Layout.preferredHeight: 30
                            radius: 8
                            color: island.accentColor
                            visible: island.bluetooth && island.bluetooth.promptMode !== "display"

                            Text {
                                anchors.centerIn: parent
                                text: island.bluetooth && island.bluetooth.promptNeedsInput ? "PAIR" : "CONFIRM"
                                color: island.onAccentColor
                                font.family: island.monoFont
                                font.pixelSize: Math.round(9 * island.fontScale)
                                font.weight: Font.Bold
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!island.bluetooth)
                                        return;
                                    if (island.bluetooth.promptNeedsInput)
                                        island.submitBluetoothPasskey();
                                    else
                                        island.bluetooth.acceptPrompt();
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30
                            radius: 8
                            color: island.accentColor
                            visible: island.bluetooth && island.bluetooth.promptMode === "display"

                            Text {
                                anchors.centerIn: parent
                                text: "DONE"
                                color: island.onAccentColor
                                font.family: island.monoFont
                                font.pixelSize: Math.round(9 * island.fontScale)
                                font.weight: Font.Bold
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (island.bluetooth)
                                        island.bluetooth.dismissPrompt();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    PopupWindow {
        id: notificationCenterPopup

        anchor.window: island.panelWindow
        anchor.rect.x: {
            if (!island.panelWindow)
                return 0;
            const bell = bellItem.mapToItem(island, 0, 0);
            const visualLeft = island.x + (island.width - island.width * island.uiScale) / 2;
            const desired = Math.round(visualLeft + (bell.x + bellItem.width / 2) * island.uiScale - implicitWidth / 2);
            return Math.max(16, Math.min(desired, island.panelWindow.width - implicitWidth - 16));
        }
        anchor.rect.y: {
            const bell = bellItem.mapToItem(island, 0, 0);
            return Math.round(island.y + (bell.y + bellItem.height) * island.uiScale + 8);
        }
        visible: false
        grabFocus: true
        implicitWidth: 360
        implicitHeight: 420
        color: "transparent"

        onVisibleChanged: {
            if (notificationCenterPopup.visible)
                Qt.callLater(() => notificationCenterEscapeFocus.forceActiveFocus());
        }

        onClosed: {
            if (island.notifications && island.notifications.centerOpen)
                island.closeNotificationCenter();
        }

        Rectangle {
            anchors.fill: parent
            radius: 14
            color: Qt.rgba(island.bgColor.r, island.bgColor.g, island.bgColor.b, 0.98)
            border.width: 1
            border.color: island.borderMutedColor
            clip: true

            FocusScope {
                id: notificationCenterEscapeFocus

                anchors.fill: parent
                focus: island.notifications && island.notifications.centerOpen
                Keys.onEscapePressed: island.closeNotificationCenter()
            }

            Shortcut {
                sequence: "Esc"
                enabled: island.notifications && island.notifications.centerOpen
                onActivated: island.closeNotificationCenter()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "NOTIFICATIONS"
                        color: island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(10 * island.fontScale)
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: island.notifications ? island.notifications.history.length : "0"
                        color: island.borderColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(9 * island.fontScale)
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "CLEAR"
                        color: island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(8 * island.fontScale)
                        font.weight: Font.DemiBold

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (island.notifications)
                                    island.notifications.clearAll();
                                island.releaseHoverKeyboard();
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: island.mutedColor
                            font.family: island.monoFont
                            font.pixelSize: Math.round(12 * island.fontScale)
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: island.closeNotificationCenter()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: island.borderMutedColor
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ListView {
                        anchors.fill: parent
                        clip: true
                        spacing: 4
                        model: island.notifications ? island.notifications.groups : []

                        delegate: Column {
                            id: notificationGroup

                            required property var modelData

                            readonly property var group: modelData

                            width: ListView.view.width
                            spacing: 3

                            Rectangle {
                                id: groupHeader

                                width: parent.width
                                height: 66
                                radius: 8
                                color: groupHover.hovered ? island.surfaceHighColor : "transparent"

                                HoverHandler {
                                    id: groupHover
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 8

                                    Rectangle {
                                        Layout.preferredWidth: 36
                                        Layout.preferredHeight: 36
                                        radius: 8
                                        color: island.surfaceHighColor
                                        clip: true

                                        Image {
                                            id: groupImage
                                            anchors.fill: parent
                                            source: notificationGroup.group.items.length > 0
                                                ? notificationGroup.group.items[0].image
                                                : ""
                                            sourceSize.width: 36
                                            sourceSize.height: 36
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                            cache: true
                                            visible: notificationGroup.group.items.length > 0
                                                && notificationGroup.group.items[0].image.length > 0
                                                && status === Image.Ready
                                        }

                                        IconImage {
                                            id: groupIcon
                                            anchors.centerIn: parent
                                            visible: !groupImage.visible
                                            source: island.notifications
                                                ? island.notifications.resolveIcon(notificationGroup.group.appIcon)
                                                : ""
                                            implicitSize: 22
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            visible: !groupImage.visible && groupIcon.status !== Image.Ready
                                            text: "󰂚"
                                            color: island.mutedColor
                                            font.family: island.monoFont
                                            font.pixelSize: Math.round(17 * island.fontScale)
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 5

                                            Text {
                                                Layout.fillWidth: true
                                                text: notificationGroup.group.appName
                                                color: island.mutedColor
                                                font.family: island.monoFont
                                                font.pixelSize: Math.round(9 * island.fontScale)
                                                font.weight: Font.DemiBold
                                                elide: Text.ElideRight
                                                maximumLineCount: 1
                                            }

                                            Text {
                                                visible: notificationGroup.group.count > 1
                                                text: "×" + notificationGroup.group.count
                                                color: island.borderColor
                                                font.family: island.monoFont
                                                font.pixelSize: Math.round(8 * island.fontScale)
                                                font.weight: Font.DemiBold
                                            }

                                            Rectangle {
                                                visible: notificationGroup.group.items.length > 0
                                                    && notificationGroup.group.items[0].urgency === NotificationUrgency.Critical
                                                width: 5
                                                height: 5
                                                radius: 3
                                                color: island.errorColor
                                            }

                                            Text {
                                                text: notificationGroup.group.items.length > 0
                                                    ? Qt.formatTime(new Date(notificationGroup.group.items[0].timestamp), "hh:mm")
                                                    : ""
                                                color: island.borderColor
                                                font.family: island.monoFont
                                                font.pixelSize: Math.round(8 * island.fontScale)
                                            }

                                            Text {
                                                text: notificationGroup.group.expanded ? "▾" : "▸"
                                                color: island.mutedColor
                                                font.family: island.monoFont
                                                font.pixelSize: Math.round(10 * island.fontScale)
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: notificationGroup.group.items.length > 0
                                                ? notificationGroup.group.items[0].summary
                                                : ""
                                            color: island.fgColor
                                            font.family: island.monoFont
                                            font.pixelSize: Math.round(10 * island.fontScale)
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                            textFormat: Text.PlainText
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: notificationGroup.group.items.length > 0
                                                ? notificationGroup.group.items[0].body
                                                : ""
                                            color: island.mutedColor
                                            font.family: island.monoFont
                                            font.pixelSize: Math.round(8 * island.fontScale)
                                            wrapMode: Text.Wrap
                                            elide: Text.ElideRight
                                            maximumLineCount: 2
                                            textFormat: Text.PlainText
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (island.notifications)
                                            island.notifications.toggleGroup(notificationGroup.group.key);
                                    }
                                }
                            }

                            Repeater {
                                model: notificationGroup.group.expanded ? notificationGroup.group.items : []

                                delegate: Rectangle {
                                    id: messageRow

                                    required property var modelData

                                    width: notificationGroup.width
                                    height: 62
                                    radius: 7
                                    color: messageHover.hovered ? island.surfaceHighColor : "transparent"

                                    HoverHandler {
                                        id: messageHover
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 12
                                        anchors.rightMargin: 6
                                        anchors.topMargin: 5
                                        anchors.bottomMargin: 5
                                        spacing: 8

                                        Rectangle {
                                            Layout.preferredWidth: 2
                                            Layout.fillHeight: true
                                            Layout.topMargin: 4
                                            Layout.bottomMargin: 4
                                            radius: 1
                                            color: island.borderMutedColor
                                            opacity: 0.6
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 0

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 5

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: messageRow.modelData.summary.length > 0
                                                        ? messageRow.modelData.summary
                                                        : messageRow.modelData.appName
                                                    color: island.fgColor
                                                    font.family: island.monoFont
                                                    font.pixelSize: Math.round(9 * island.fontScale)
                                                    font.weight: Font.DemiBold
                                                    elide: Text.ElideRight
                                                    maximumLineCount: 1
                                                    textFormat: Text.PlainText
                                                }

                                                Text {
                                                    text: Qt.formatTime(new Date(messageRow.modelData.timestamp), "hh:mm")
                                                    color: island.borderColor
                                                    font.family: island.monoFont
                                                    font.pixelSize: Math.round(7 * island.fontScale)
                                                }
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: messageRow.modelData.body
                                                color: island.mutedColor
                                                font.family: island.monoFont
                                                font.pixelSize: Math.round(8 * island.fontScale)
                                                wrapMode: Text.Wrap
                                                elide: Text.ElideRight
                                                maximumLineCount: 3
                                                textFormat: Text.PlainText
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !island.notifications || island.notifications.history.length === 0
                        text: "No notifications"
                        color: island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(10 * island.fontScale)
                    }
                }
            }
        }
    }

    MediaCard {
        anchors.fill: parent
        visible: island.mode === "media"
        media: island.media
        fontScale: island.fontScale
        monoFont: island.monoFont
        bgColor: island.bgColor
        surfaceHighColor: island.surfaceHighColor
        fgColor: island.fgColor
        mutedColor: island.mutedColor
        accentColor: island.accentColor
        secondaryColor: island.secondaryColor
        onAccentColor: island.onAccentColor
        errorColor: island.errorColor
        borderMutedColor: island.borderMutedColor
    }

    NotificationCard {
        anchors.fill: parent
        visible: island.mode === "notification"
        notifications: island.notifications
        fontScale: island.fontScale
        monoFont: island.monoFont
        bgColor: island.bgColor
        surfaceHighColor: island.surfaceHighColor
        fgColor: island.fgColor
        mutedColor: island.mutedColor
        accentColor: island.accentColor
        onAccentColor: island.onAccentColor
        errorColor: island.errorColor
        borderMutedColor: island.borderMutedColor
    }

    Row {
        id: collapsedRow
        anchors.centerIn: parent
        spacing: island.collapsedItemSpacing
        visible: island.mode === "collapsed"

        Repeater {
            model: island.collapsedItems

            delegate: CollapsedItem {
                host: island
                itemType: modelData
            }
        }

        CollapsedItem {
            host: island
            itemType: "notifications"
            visible: island.showCollapsedUnreadBell
        }

        PrivacyIndicator {
            host: island
        }
    }

    RowLayout {
        id: volumeRow
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8
        visible: island.mode === "volume"

        Text {
            text: island.volume ? island.volume.icon : "󰖁"
            color: island.volume && island.volume.muted ? island.mutedColor : island.accentColor
            font.family: island.monoFont
            font.pixelSize: Math.round(16 * island.fontScale)
            font.weight: Font.Medium
        }

        Text {
            text: island.volume && island.volume.muted ? "MUTE" : "VOL"
            color: island.mutedColor
            font.family: island.monoFont
            font.pixelSize: Math.round(9 * island.fontScale)
            font.weight: Font.DemiBold
        }

        Text {
            Layout.preferredWidth: 42
            text: island.volume ? island.volume.levelText : "--"
            color: island.volume && island.volume.muted ? island.mutedColor : island.accentColor
            font.family: island.monoFont
            font.pixelSize: Math.round(12 * island.fontScale)
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignRight
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 5
            radius: 3
            color: island.surfaceHighColor

            Rectangle {
                width: parent.width * (island.volume ? island.volume.progress : 0)
                height: parent.height
                radius: parent.radius
                color: island.volume && island.volume.muted ? island.mutedColor : island.accentColor

                Behavior on width {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                anchors.topMargin: -6
                anchors.bottomMargin: -6
                cursorShape: Qt.PointingHandCursor
                preventStealing: true

                function applyVolume(x) {
                    if (island.volume)
                        island.volume.setLevel(Math.round(Math.max(0, Math.min(width, x)) / width * 100));
                }

                onPressed: mouse => applyVolume(mouse.x)
                onPositionChanged: mouse => {
                    if (pressed)
                        applyVolume(mouse.x);
                }
            }
        }
    }

    RowLayout {
        id: brightnessRow
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8
        visible: island.mode === "brightness"

        Text {
            text: island.brightness ? island.brightness.icon : "󰃞"
            color: island.accentColor
            font.family: island.monoFont
            font.pixelSize: Math.round(16 * island.fontScale)
            font.weight: Font.Medium
        }

        Text {
            text: "BRT"
            color: island.mutedColor
            font.family: island.monoFont
            font.pixelSize: Math.round(9 * island.fontScale)
            font.weight: Font.DemiBold
        }

        Text {
            Layout.preferredWidth: 42
            text: island.brightness ? island.brightness.percentText : "--"
            color: island.accentColor
            font.family: island.monoFont
            font.pixelSize: Math.round(12 * island.fontScale)
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignRight
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 5
            radius: 3
            color: island.surfaceHighColor

            Rectangle {
                width: parent.width * (island.brightness ? Math.max(0, island.brightness.percent) / 100 : 0)
                height: parent.height
                radius: parent.radius
                color: island.accentColor

                Behavior on width {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                anchors.topMargin: -6
                anchors.bottomMargin: -6
                cursorShape: Qt.PointingHandCursor
                preventStealing: true

                function applyBrightness(x) {
                    if (island.brightness)
                        island.brightness.setPercent(Math.round(Math.max(0, Math.min(width, x)) / width * 100));
                }

                onPressed: mouse => applyBrightness(mouse.x)
                onPositionChanged: mouse => {
                    if (pressed)
                        applyBrightness(mouse.x);
                }
            }
        }
    }

    RowLayout {
        id: keyboardLayoutRow
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8
        visible: island.mode === "keyboardLayout"

        Text {
            text: "󰌌"
            color: island.accentColor
            font.family: island.monoFont
            font.pixelSize: Math.round(16 * island.fontScale)
            font.weight: Font.Medium
        }

        Text {
            text: "LAYOUT"
            color: island.mutedColor
            font.family: island.monoFont
            font.pixelSize: Math.round(9 * island.fontScale)
            font.weight: Font.DemiBold
        }

        Text {
            Layout.fillWidth: true
            text: island.keyboardLayout ? island.keyboardLayout.currentLabel : "—"
            color: island.fgColor
            font.family: island.monoFont
            font.pixelSize: Math.round(11 * island.fontScale)
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignRight
        }

        Text {
            text: island.keyboardLayout ? island.keyboardLayout.positionText : ""
            color: island.mutedColor
            font.family: island.monoFont
            font.pixelSize: Math.round(8 * island.fontScale)
        }
    }


    RowLayout {
        id: layoutOsdRow
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 9
        visible: island.mode === "layout"

        Text {
            text: "󰕴"
            color: island.accentColor
            font.family: island.monoFont
            font.pixelSize: Math.round(16 * island.fontScale)
            font.weight: Font.Medium
        }

        Text {
            text: "WM LAYOUT"
            color: island.mutedColor
            font.family: island.monoFont
            font.pixelSize: Math.round(9 * island.fontScale)
            font.weight: Font.DemiBold
        }

        Text {
            Layout.fillWidth: true
            text: island.layoutOsdText
            color: island.fgColor
            font.family: island.monoFont
            font.pixelSize: Math.round(12 * island.fontScale)
            font.weight: Font.Bold
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignRight
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
            font.pixelSize: Math.round(10 * island.fontScale)
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
                font.pixelSize: Math.round(12 * island.fontScale)
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
            font.pixelSize: Math.round(12 * island.fontScale)
            font.weight: Font.Medium
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    ColumnLayout {
        id: dashboard
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10
        visible: island.mode === "expanded"

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            spacing: 8

            Text {
                text: island.timeText
                color: island.accentColor
                font.family: island.monoFont
                font.pixelSize: Math.round(12 * island.fontScale)
                font.weight: Font.DemiBold
                font.letterSpacing: 0.3
            }

            Text {
                visible: island.batteryCriticalActive
                text: island.stats ? island.stats.batteryIcon : "󰂎"
                color: island.errorColor
                font.family: island.monoFont
                font.pixelSize: Math.round(11 * island.fontScale)
                font.weight: Font.Medium
            }

            Row {
                visible: island.showWorkspaceTags
                spacing: 4

                Repeater {
                    model: island.visibleTags

                    delegate: Rectangle {
                        id: dashboardTag

                        required property var modelData

                        readonly property var tag: dashboardTag.modelData
                        readonly property bool active: dashboardTag.tag ? dashboardTag.tag.is_active : false
                        readonly property bool occupied: dashboardTag.tag ? dashboardTag.tag.client_count > 0 : false
                        readonly property bool urgent: dashboardTag.tag ? dashboardTag.tag.is_urgent : false
                        property bool hovered: false

                        width: 22
                        height: 22
                        radius: 7
                        color: dashboardTag.active ? island.accentColor : (dashboardTag.hovered ? island.surfaceHighColor : "transparent")
                        border.width: dashboardTag.active ? 0 : 1
                        border.color: dashboardTag.urgent
                            ? island.errorColor
                            : (dashboardTag.occupied ? island.borderColor : island.borderMutedColor)

                        Text {
                            anchors.centerIn: parent
                            text: dashboardTag.tag ? dashboardTag.tag.index : ""
                            color: dashboardTag.active ? island.onAccentColor : (dashboardTag.occupied ? island.fgColor : island.mutedColor)
                            font.family: island.monoFont
                            font.pixelSize: Math.round(10 * island.fontScale)
                            font.weight: dashboardTag.active ? Font.Bold : Font.Medium
                        }

                        Rectangle {
                            visible: island.showOccupiedIndicator && dashboardTag.occupied && !dashboardTag.active
                            width: 3
                            height: 3
                            radius: 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 2
                            color: island.accentColor
                        }

                        HoverHandler {
                            onHoveredChanged: dashboardTag.hovered = hovered
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: island.mango.switchTag(dashboardTag.tag.index)
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 26
                spacing: 6

                IconImage {
                    visible: island.showWindowInfo && island.appIconSource.length > 0
                    source: island.appIconSource
                    implicitSize: 20
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    visible: island.showWindowInfo
                    Layout.fillWidth: false
                    Layout.maximumWidth: 80
                    text: island.windowTitle
                    color: island.fgColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(11 * island.fontScale)
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    text: "LAYOUT"
                    color: island.mutedColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(8 * island.fontScale)
                    font.weight: Font.DemiBold
                }

                Text {
                    text: island.layoutSymbol
                    color: island.tertiaryColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(10 * island.fontScale)
                    font.weight: Font.Bold
                }

                Row {
                    id: trayRow
                    spacing: 4

                    Repeater {
                        model: SystemTray.items

                        delegate: TrayIcon {
                            required property var modelData
                            required property int index

                            width: index < 3 ? 18 : 0
                            height: 18
                            visible: index < 3
                            trayItem: modelData
                            host: island
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: island.borderMutedColor
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 30
            spacing: 16

            Item {
                id: wifiItem

                Layout.preferredWidth: wifiContent.implicitWidth + 18
                Layout.preferredHeight: 28

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: Qt.rgba(island.surfaceHighColor.r, island.surfaceHighColor.g, island.surfaceHighColor.b, wifiMouse.containsMouse ? 0.8 : 0.5)
                }

                Row {
                    id: wifiContent
                    anchors.left: parent.left
                    anchors.leftMargin: 9
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

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
                        font.pixelSize: Math.round(12 * island.fontScale)
                        font.weight: Font.Medium
                    }

                    Text {
                        visible: island.showNetworkName
                        text: island.network ? island.network.label : "--"
                        width: Math.min(implicitWidth, 72)
                        color: island.network && island.network.connected ? island.fgColor : island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(8 * island.fontScale)
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: wifiMouse

                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
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

            Item {
                id: bluetoothItem

                Layout.preferredWidth: bluetoothContent.implicitWidth + 18
                Layout.preferredHeight: 28
                opacity: island.bluetooth && island.bluetooth.busy ? 0.5 : 1

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: Qt.rgba(island.surfaceHighColor.r, island.surfaceHighColor.g, island.surfaceHighColor.b, bluetoothMouse.containsMouse ? 0.8 : 0.5)
                }

                Row {
                    id: bluetoothContent
                    anchors.left: parent.left
                    anchors.leftMargin: 9
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    Text {
                        text: island.bluetooth ? island.bluetooth.icon : "󰂲"
                        color: island.bluetooth && island.bluetooth.enabled
                            ? (island.bluetooth.connectedCount > 0 ? island.secondaryColor : island.accentColor)
                            : island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(12 * island.fontScale)
                        font.weight: Font.Medium
                    }

                    Text {
                        visible: island.showBluetoothStatus
                        text: island.bluetooth ? island.bluetooth.label : "--"
                        color: island.bluetooth && island.bluetooth.enabled ? island.fgColor : island.mutedColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(8 * island.fontScale)
                        font.weight: Font.DemiBold
                    }
                }

                MouseArea {
                    id: bluetoothMouse

                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        if (!island.bluetooth)
                            return;
                        if (mouse.button === Qt.RightButton)
                            island.bluetooth.toggle();
                        else
                            island.toggleBluetoothMenu();
                    }
                }
            }

            Item {
                id: powerItem

                Layout.preferredWidth: powerContent.implicitWidth + 18
                Layout.preferredHeight: 28
                opacity: island.power && island.power.busy ? 0.5 : 1

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: Qt.rgba(island.surfaceHighColor.r, island.surfaceHighColor.g, island.surfaceHighColor.b, powerMouse.containsMouse ? 0.8 : 0.5)
                }

                Row {
                    id: powerContent
                    anchors.left: parent.left
                    anchors.leftMargin: 9
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    Text {
                        text: island.power ? island.power.icon : "󰾅"
                        color: island.powerColor()
                        font.family: island.monoFont
                        font.pixelSize: Math.round(12 * island.fontScale)
                        font.weight: Font.Medium
                    }

                    Text {
                        text: island.power ? island.power.label : "--"
                        color: island.fgColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(8 * island.fontScale)
                        font.weight: Font.DemiBold
                    }
                }

                MouseArea {
                    id: powerMouse

                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (island.power)
                            island.power.cycle();
                    }
                }
            }

            Item {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: Qt.rgba(island.surfaceHighColor.r, island.surfaceHighColor.g, island.surfaceHighColor.b, settingsMouse.containsMouse ? 0.8 : 0.5)
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰒓"
                    color: settingsMouse.containsMouse ? island.accentColor : island.fgColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(14 * island.fontScale)
                }

                MouseArea {
                    id: settingsMouse

                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: island.toggleSettings()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: island.borderMutedColor
        }

        Rectangle {
            visible: island.privacy && island.privacy.microphoneActive
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            radius: 7
            color: Qt.rgba(island.errorColor.r, island.errorColor.g, island.errorColor.b, 0.12)
            border.width: 1
            border.color: Qt.rgba(island.errorColor.r, island.errorColor.g, island.errorColor.b, 0.35)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                Text {
                    text: "󰍬"
                    color: island.errorColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(12 * island.fontScale)
                    font.weight: Font.Medium
                }

                Text {
                    text: "MIC"
                    color: island.errorColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(8 * island.fontScale)
                    font.weight: Font.Bold
                }

                Text {
                    Layout.fillWidth: true
                    text: island.privacy && island.privacy.microphoneApps.length > 0
                        ? island.privacy.microphoneApps.join(", ")
                        : "Unknown application"
                    color: island.fgColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(9 * island.fontScale)
                    elide: Text.ElideRight
                }

                Text {
                    visible: island.privacy && island.privacy.microphoneSessionCount > 1
                    text: island.privacy ? "×" + island.privacy.microphoneSessionCount : ""
                    color: island.mutedColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(8 * island.fontScale)
                    font.weight: Font.DemiBold
                }
            }
        }

        Rectangle {
            visible: island.privacy && island.privacy.screenActive
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            radius: 7
            color: Qt.rgba(island.errorColor.r, island.errorColor.g, island.errorColor.b, 0.12)
            border.width: 1
            border.color: Qt.rgba(island.errorColor.r, island.errorColor.g, island.errorColor.b, 0.35)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                Text {
                    text: "󰍹"
                    color: island.errorColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(12 * island.fontScale)
                    font.weight: Font.Medium
                }

                Text {
                    text: "SCREEN"
                    color: island.errorColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(8 * island.fontScale)
                    font.weight: Font.Bold
                }

                Text {
                    Layout.fillWidth: true
                    text: island.privacy && island.privacy.screenApps.length > 0
                        ? island.privacy.screenApps.join(", ")
                        : "Unknown application"
                    color: island.fgColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(9 * island.fontScale)
                    elide: Text.ElideRight
                }

                Text {
                    visible: island.privacy && island.privacy.screenSessionCount > 1
                    text: island.privacy ? "×" + island.privacy.screenSessionCount : ""
                    color: island.mutedColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(8 * island.fontScale)
                    font.weight: Font.DemiBold
                }
            }
        }

        RowLayout {
            visible: island.showSystemStats && island.hasVisibleStats
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 24
            spacing: 16

            Row {
                visible: island.showCpuStat
                spacing: 3

                Text {
                    text: "󰻠"
                    color: island.mutedColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(12 * island.fontScale)
                    font.weight: Font.Medium
                }

                Text {
                    text: island.stats ? island.stats.cpuText : "--"
                    color: island.fgColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(10 * island.fontScale)
                    font.weight: Font.Medium
                }
            }

            Row {
                visible: island.showRamStat
                spacing: 3

                Text {
                    text: "󰍛"
                    color: island.mutedColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(12 * island.fontScale)
                    font.weight: Font.Medium
                }

                Text {
                    text: island.stats ? island.stats.memText : "--"
                    color: island.fgColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(10 * island.fontScale)
                    font.weight: Font.Medium
                }
            }

            Row {
                visible: island.showTempStat
                spacing: 3

                Text {
                    text: "󰔏"
                    color: island.mutedColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(12 * island.fontScale)
                    font.weight: Font.Medium
                }

                Text {
                    text: island.stats ? island.stats.tempText : "--"
                    color: island.fgColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(10 * island.fontScale)
                    font.weight: Font.Medium
                }
            }

            Row {
                visible: island.showBatteryStat
                spacing: 3

                Text {
                    text: island.stats ? island.stats.batteryIcon : "󰂎"
                    color: island.batteryCriticalActive
                        ? island.errorColor
                        : (island.batteryWarningActive ? island.accentColor : island.secondaryColor)
                    font.family: island.monoFont
                    font.pixelSize: Math.round(11 * island.fontScale)
                    font.weight: Font.Medium
                }

                Text {
                    text: island.stats ? island.stats.batteryText : "--"
                    color: island.batteryCriticalActive
                        ? island.errorColor
                        : (island.batteryWarningActive ? island.accentColor : island.fgColor)
                    font.family: island.monoFont
                    font.pixelSize: Math.round(10 * island.fontScale)
                    font.weight: Font.Medium
                }
            }
        }

        Rectangle {
            visible: island.showSystemStats && island.hasVisibleStats
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: island.borderMutedColor
        }

        MediaCard {
            visible: island.showMedia && island.media && island.media.hasPlayer
            Layout.fillWidth: true
            Layout.preferredHeight: 104
            media: island.media
            showArtwork: island.showMediaArtwork
            showProgress: island.showMediaProgress
            fontScale: island.fontScale
            monoFont: island.monoFont
            bgColor: island.bgColor
            surfaceHighColor: island.surfaceHighColor
            fgColor: island.fgColor
            mutedColor: island.mutedColor
            accentColor: island.accentColor
            secondaryColor: island.secondaryColor
            onAccentColor: island.onAccentColor
            errorColor: island.errorColor
            borderMutedColor: island.borderMutedColor
        }

        Rectangle {
            visible: island.showMedia && island.media && island.media.hasPlayer
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: island.borderMutedColor
        }

        RowLayout {
            visible: island.showVolume
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 24
            spacing: 8

            Item {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22

                Text {
                    anchors.centerIn: parent
                    text: island.volume ? island.volume.icon : "󰖁"
                    color: island.volume && island.volume.muted ? island.mutedColor : island.accentColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(16 * island.fontScale)
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (island.volume)
                            island.volume.toggleMute();
                    }
                }
            }

            Text {
                text: island.volume && island.volume.muted ? "MUTE" : "VOL"
                color: island.mutedColor
                font.family: island.monoFont
                font.pixelSize: Math.round(9 * island.fontScale)
                font.weight: Font.DemiBold
            }

            Text {
                Layout.preferredWidth: 42
                text: island.volume ? island.volume.levelText : "--"
                color: island.volume && island.volume.muted ? island.mutedColor : island.accentColor
                font.family: island.monoFont
                font.pixelSize: Math.round(11 * island.fontScale)
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignRight
            }

            Rectangle {
                Layout.preferredWidth: 170
                Layout.preferredHeight: 4
                radius: 2
                color: island.surfaceHighColor

                Rectangle {
                    width: parent.width * (island.volume ? island.volume.progress : 0)
                    height: parent.height
                    radius: parent.radius
                    color: island.volume && island.volume.muted ? island.mutedColor : island.accentColor

                    Behavior on width {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.topMargin: -7
                    anchors.bottomMargin: -7
                    cursorShape: Qt.PointingHandCursor
                    preventStealing: true

                    function applyVolume(x) {
                        if (island.volume)
                            island.volume.setLevel(
                                Math.round(Math.max(0, Math.min(width, x)) / width * 100), false);
                    }

                    onPressed: mouse => applyVolume(mouse.x)
                    onPositionChanged: mouse => {
                        if (pressed)
                            applyVolume(mouse.x);
                    }
                }
            }
        }

        RowLayout {
            visible: island.showBrightness && island.brightness && island.brightness.available
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 24
            spacing: 8

            Item {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22

                Text {
                    anchors.centerIn: parent
                    text: island.brightness ? island.brightness.icon : "󰃞"
                    color: island.accentColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(16 * island.fontScale)
                }
            }

            Text {
                text: "BRT"
                color: island.mutedColor
                font.family: island.monoFont
                font.pixelSize: Math.round(9 * island.fontScale)
                font.weight: Font.DemiBold
            }

            Text {
                Layout.preferredWidth: 42
                text: island.brightness ? island.brightness.percentText : "--"
                color: island.accentColor
                font.family: island.monoFont
                font.pixelSize: Math.round(11 * island.fontScale)
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignRight
            }

            Rectangle {
                Layout.preferredWidth: 170
                Layout.preferredHeight: 4
                radius: 2
                color: island.surfaceHighColor

                Rectangle {
                    width: parent.width * (island.brightness ? Math.max(0, island.brightness.percent) / 100 : 0)
                    height: parent.height
                    radius: parent.radius
                    color: island.accentColor

                    Behavior on width {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.topMargin: -7
                    anchors.bottomMargin: -7
                    cursorShape: Qt.PointingHandCursor
                    preventStealing: true

                    function applyBrightness(x) {
                        if (island.brightness)
                            island.brightness.setPercent(
                                Math.round(Math.max(0, Math.min(width, x)) / width * 100), false);
                    }

                    onPressed: mouse => applyBrightness(mouse.x)
                    onPositionChanged: mouse => {
                        if (pressed)
                            applyBrightness(mouse.x);
                    }
                }
            }
        }

        RowLayout {
            visible: island.showExternalBrightness && island.ddcBrightness && island.ddcBrightness.available
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 24
            spacing: 8

            Item {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22

                Text {
                    anchors.centerIn: parent
                    text: island.ddcBrightness ? island.ddcBrightness.icon : "󰃞"
                    color: island.secondaryColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(16 * island.fontScale)
                }
            }

            Text {
                text: "EXT"
                color: island.mutedColor
                font.family: island.monoFont
                font.pixelSize: Math.round(9 * island.fontScale)
                font.weight: Font.DemiBold
            }

            Text {
                Layout.preferredWidth: 42
                text: island.ddcBrightness ? island.ddcBrightness.percentText : "--"
                color: island.secondaryColor
                font.family: island.monoFont
                font.pixelSize: Math.round(11 * island.fontScale)
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignRight
            }

            Rectangle {
                Layout.preferredWidth: 170
                Layout.preferredHeight: 4
                radius: 2
                color: island.surfaceHighColor

                Rectangle {
                    width: parent.width * (island.ddcBrightness ? Math.max(0, island.ddcBrightness.percent) / 100 : 0)
                    height: parent.height
                    radius: parent.radius
                    color: island.secondaryColor

                    Behavior on width {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.topMargin: -7
                    anchors.bottomMargin: -7
                    cursorShape: Qt.PointingHandCursor
                    preventStealing: true

                    function applyExternalBrightness(x) {
                        if (island.ddcBrightness)
                            island.ddcBrightness.setPercent(
                                Math.round(Math.max(0, Math.min(width, x)) / width * 100));
                    }

                    onPressed: mouse => applyExternalBrightness(mouse.x)
                    onPositionChanged: mouse => {
                        if (pressed)
                            applyExternalBrightness(mouse.x);
                    }
                }
            }
        }

        Rectangle {
            visible: island.showVolume
                || (island.showBrightness && island.brightness && island.brightness.available)
                || (island.showExternalBrightness && island.ddcBrightness && island.ddcBrightness.available)
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: island.borderMutedColor
        }

        ColumnLayout {
            visible: island.showNotifications
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 3

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                spacing: 6

                Text {
                    text: "NOTIFICATIONS"
                    color: island.mutedColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(9 * island.fontScale)
                    font.weight: Font.DemiBold
                }

                Text {
                    text: island.notifications ? island.notifications.history.length : "0"
                    color: island.borderColor
                    font.family: island.monoFont
                    font.pixelSize: Math.round(8 * island.fontScale)
                }

                Item {
                    Layout.fillWidth: true
                }

                Item {
                    id: bellItem

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
                        font.pixelSize: Math.round(14 * island.fontScale)
                        font.weight: Font.Medium
                    }

                    Rectangle {
                        visible: island.notifications && island.notifications.unreadCount > 0
                        width: 14
                        height: 14
                        radius: 7
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: -4
                        anchors.topMargin: -4
                        color: island.errorColor

                        Text {
                            anchors.centerIn: parent
                            text: island.notifications && island.notifications.unreadCount > 9
                                ? "9+"
                                : (island.notifications ? island.notifications.unreadCount : "")
                            color: island.onAccentColor
                            font.family: island.monoFont
                            font.pixelSize: Math.round(7 * island.fontScale)
                            font.weight: Font.Bold
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: island.toggleNotificationCenter()
                    }
                }
            }

            Repeater {
                model: island.notifications ? island.notifications.history.slice(0, 2) : []

                delegate: RowLayout {
                    id: dashboardNotification

                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    spacing: 5

                    Rectangle {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        radius: 4
                        color: island.surfaceHighColor
                        clip: true

                        Image {
                            id: dashboardNotificationImage
                            anchors.fill: parent
                            source: dashboardNotification.modelData.image
                            sourceSize.width: 16
                            sourceSize.height: 16
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            visible: island.showNotificationImages
                                && dashboardNotification.modelData.image.length > 0
                                && status === Image.Ready
                        }

                        IconImage {
                            id: dashboardNotificationIcon
                            anchors.centerIn: parent
                            visible: !dashboardNotificationImage.visible
                            source: island.notifications
                                ? island.notifications.resolveIcon(dashboardNotification.modelData.appIcon)
                                : ""
                            implicitSize: 11
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !dashboardNotificationImage.visible && dashboardNotificationIcon.status !== Image.Ready
                            text: "󰂚"
                            color: island.mutedColor
                            font.family: island.monoFont
                            font.pixelSize: Math.round(9 * island.fontScale)
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                Layout.fillWidth: true
                                text: dashboardNotification.modelData.summary.length > 0
                                    ? dashboardNotification.modelData.summary
                                    : dashboardNotification.modelData.appName
                                color: island.fgColor
                                font.family: island.monoFont
                                font.pixelSize: Math.round(9 * island.fontScale)
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                textFormat: Text.PlainText
                            }

                            Rectangle {
                                visible: dashboardNotification.modelData.urgency === NotificationUrgency.Critical
                                width: 5
                                height: 5
                                radius: 3
                                color: island.errorColor
                            }

                            Text {
                                text: Qt.formatTime(new Date(dashboardNotification.modelData.timestamp), "hh:mm")
                                color: island.borderColor
                                font.family: island.monoFont
                                font.pixelSize: Math.round(8 * island.fontScale)
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: dashboardNotification.modelData.body.length > 0
                            text: dashboardNotification.modelData.body
                            color: island.mutedColor
                            font.family: island.monoFont
                            font.pixelSize: Math.round(8 * island.fontScale)
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            textFormat: Text.PlainText
                        }
                    }

                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: island.toggleNotificationCenter()
                    }
                }
            }

            Item {
                visible: !island.notifications || island.notifications.history.length === 0
                Layout.fillWidth: true
                Layout.fillHeight: true

                Column {
                    anchors.centerIn: parent
                    spacing: 5

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰂚"
                        color: island.borderColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(20 * island.fontScale)
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No notifications"
                        color: island.borderColor
                        font.family: island.monoFont
                        font.pixelSize: Math.round(8 * island.fontScale)
                    }
                }
            }
        }

        Item {
            visible: !island.showNotifications
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Loader {
        anchors.fill: parent
        active: island.mode === "settings"
        sourceComponent: Component {
            SettingsPanel {
                anchors.fill: parent
                visible: true
                monoFont: island.monoFont
                surfaceHighColor: island.surfaceHighColor
                fgColor: island.fgColor
                mutedColor: island.mutedColor
                accentColor: island.accentColor
                onAccentColor: island.onAccentColor
                errorColor: island.errorColor
                borderMutedColor: island.borderMutedColor
                bgColor: island.bgColor
                diagnostics: island.diagnostics
                settings: island.settings
                privacy: island.privacy
                keyboardLayout: island.keyboardLayout
                onCloseRequested: island.closeSettings()
            }
        }
    }

}
