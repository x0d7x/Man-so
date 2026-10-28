import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property int settingsPage: 0
    property string expansionMode: "hover"
    property int animationDuration: 220
    property bool showKeyboardOsd: true
    property int keyboardOsdTimeout: 1500
    property int volumeStep: 2
    property int volumeOsdTimeout: 1500
    property int brightnessOsdTimeout: 1500
    property bool ddcSyncEnabled: true
    property int ddcSyncInterval: 5000
    property bool showNetworkName: true
    property int backgroundOpacity: 100
    property int cornerRadius: 17
    property bool borderVisible: true
    property int borderWidth: 1
    property string fontFamily: "JetBrainsMono Nerd Font Mono"
    property bool showWorkspaceTags: true
    property bool showWindowInfo: true
    property bool showSystemStats: true
    property bool showMedia: true
    property bool showVolume: true
    property bool showBrightness: true
    property bool showExternalBrightness: true
    property bool showNotifications: true
    property bool showCpuStat: true
    property bool showRamStat: true
    property bool showTempStat: true
    property bool showBatteryStat: true
    property bool showMediaArtwork: true
    property bool showMediaProgress: true
    property int mediaOsdTimeout: 4000
    property int notificationOsdTimeout: 6000
    property int notificationHistoryLimit: 50
    property bool showNotificationImages: true
    property bool showBluetoothStatus: true
    property bool privacyEnabled: true
    property bool privacyMicrophoneEnabled: true
    property bool privacyScreenEnabled: true
    property bool privacyShowCollapsed: true
    property int cpuRefreshInterval: 300
    property int batteryWarningThreshold: 20
    property int batteryCriticalThreshold: 10
    property int fontSize: 11
    property int uiScale: 100
    property string workspaceVisibility: "all"
    property bool showOccupiedIndicator: true
    property bool includeUrgentWorkspaces: true
    property var collapsedItems: ["time"]
    property int collapsedItemSpacing: 4
    property int collapsedPadding: 14
    property bool initialized: false
    property bool loading: false
    property string lastError: ""

    readonly property string configBaseDir: {
        const xdg = Quickshell.env("XDG_CONFIG_HOME");
        return xdg && xdg.length > 0
            ? xdg
            : Quickshell.env("HOME") + "/.config";
    }
    readonly property string configDir: root.configBaseDir + "/maneso"
    readonly property string configPath: root.configDir + "/settings.json"
    readonly property string legacyConfigDir: root.configBaseDir + "/man-qs"
    readonly property string legacyConfigPath: root.legacyConfigDir + "/settings.json"

    function clampPage(value) {
        const page = Number(value);
        if (!Number.isFinite(page))
            return 0;
        return Math.max(0, Math.min(8, Math.round(page)));
    }

    function clampAnimationDuration(value) {
        const duration = Number(value);
        if (!Number.isFinite(duration))
            return 220;
        return Math.max(80, Math.min(600, Math.round(duration / 10) * 10));
    }

    function resetGeneral() {
        root.expansionMode = "hover";
        root.animationDuration = 220;
    }

    function clampBackgroundOpacity(value) {
        const opacity = Number(value);
        if (!Number.isFinite(opacity))
            return 100;
        return Math.max(40, Math.min(100, Math.round(opacity)));
    }

    function clampCornerRadius(value) {
        const radius = Number(value);
        if (!Number.isFinite(radius))
            return 17;
        return Math.max(8, Math.min(32, Math.round(radius)));
    }

    function clampBorderWidth(value) {
        const width = Number(value);
        if (!Number.isFinite(width))
            return 1;
        return Math.max(1, Math.min(4, Math.round(width)));
    }

    function clampFontFamily(value) {
        return typeof value === "string" && value.trim().length > 0
            ? value
            : "JetBrainsMono Nerd Font Mono";
    }

    function clampCpuRefreshInterval(value) {
        const interval = Number(value);
        if (!Number.isFinite(interval))
            return 300;
        return Math.max(250, Math.min(2000, Math.round(interval / 50) * 50));
    }

    function clampBatteryWarning(value) {
        const level = Number(value);
        if (!Number.isFinite(level))
            return 20;
        return Math.max(5, Math.min(50, Math.round(level / 5) * 5));
    }

    function clampBatteryCritical(value) {
        const level = Number(value);
        if (!Number.isFinite(level))
            return 10;
        return Math.max(1, Math.min(20, Math.round(level)));
    }

    function clampOsdTimeout(value) {
        const timeout = Number(value);
        if (!Number.isFinite(timeout))
            return 1500;
        return Math.max(800, Math.min(4000, Math.round(timeout / 100) * 100));
    }

    function clampKeyboardOsdTimeout(value) {
        return root.clampOsdTimeout(value);
    }

    function clampVolumeStep(value) {
        const step = Number(value);
        if (!Number.isFinite(step))
            return 2;
        return Math.max(1, Math.min(10, Math.round(step)));
    }

    function clampDdcSyncInterval(value) {
        const interval = Number(value);
        if (!Number.isFinite(interval))
            return 5000;
        return Math.max(2000, Math.min(15000, Math.round(interval / 1000) * 1000));
    }

    function clampMediaOsdTimeout(value) {
        const timeout = Number(value);
        if (!Number.isFinite(timeout))
            return 4000;
        return Math.max(1000, Math.min(10000, Math.round(timeout / 100) * 100));
    }

    function clampNotificationOsdTimeout(value) {
        const timeout = Number(value);
        if (!Number.isFinite(timeout))
            return 6000;
        return Math.max(2200, Math.min(12000, Math.round(timeout / 100) * 100));
    }

    function clampNotificationHistoryLimit(value) {
        const limit = Number(value);
        if (!Number.isFinite(limit))
            return 50;
        return Math.max(10, Math.min(100, Math.round(limit / 5) * 5));
    }

    function clampWorkspaceVisibility(value) {
        return value === "occupied" || value === "active" ? value : "all";
    }

    function clampCollapsedItemSpacing(value) {
        const spacing = Number(value);
        if (!Number.isFinite(spacing))
            return 4;
        return Math.max(0, Math.min(12, Math.round(spacing)));
    }

    function clampCollapsedPadding(value) {
        const padding = Number(value);
        if (!Number.isFinite(padding))
            return 14;
        return Math.max(8, Math.min(24, Math.round(padding)));
    }

    readonly property var collapsedItemKeys: [
        "time", "workspace", "window", "layout", "cpu", "ram", "temp", "battery",
        "wifi", "bluetooth", "power", "volume", "brightness", "externalBrightness", "media", "notifications", "tray"
    ]

    function sanitizeCollapsedItems(value) {
        const result = [];
        if (Array.isArray(value)) {
            for (let i = 0; i < value.length; ++i) {
                const key = String(value[i]);
                if (root.collapsedItemKeys.indexOf(key) !== -1 && result.indexOf(key) === -1)
                    result.push(key);
            }
        }
        if (result.indexOf("time") === -1)
            result.unshift("time");
        return result;
    }

    function hasCollapsedItem(key) {
        return root.collapsedItems.indexOf(key) !== -1;
    }

    function toggleCollapsedItem(key) {
        if (key === "time" || root.collapsedItemKeys.indexOf(key) === -1)
            return;
        const list = root.collapsedItems.slice();
        const index = list.indexOf(key);
        if (index === -1)
            list.push(key);
        else
            list.splice(index, 1);
        root.collapsedItems = list;
    }

    function moveCollapsedItem(key, delta) {
        const list = root.collapsedItems.slice();
        const index = list.indexOf(key);
        const target = index + delta;
        if (index < 0 || target < 0 || target >= list.length)
            return;
        list[index] = list[target];
        list[target] = key;
        root.collapsedItems = list;
    }

    function resetCollapsedItems() {
        root.collapsedItems = ["time"];
        root.collapsedItemSpacing = 4;
        root.collapsedPadding = 14;
    }

    function resetMango() {
        root.workspaceVisibility = "all";
        root.showOccupiedIndicator = true;
        root.includeUrgentWorkspaces = true;
    }

    function resetPower() {
        root.cpuRefreshInterval = 300;
        root.batteryWarningThreshold = 20;
        root.batteryCriticalThreshold = 10;
    }

    function resetModules() {
        root.showWorkspaceTags = true;
        root.showWindowInfo = true;
        root.showSystemStats = true;
        root.showMedia = true;
        root.showVolume = true;
        root.showBrightness = true;
        root.showExternalBrightness = true;
        root.showNotifications = true;
        root.volumeStep = 2;
        root.volumeOsdTimeout = 1500;
        root.brightnessOsdTimeout = 1500;
        root.ddcSyncEnabled = true;
        root.ddcSyncInterval = 5000;
        root.showNetworkName = true;
        root.showCpuStat = true;
        root.showRamStat = true;
        root.showTempStat = true;
        root.showBatteryStat = true;
        root.showMediaArtwork = true;
        root.showMediaProgress = true;
        root.mediaOsdTimeout = 4000;
        root.notificationOsdTimeout = 6000;
        root.notificationHistoryLimit = 50;
        root.showNotificationImages = true;
        root.showBluetoothStatus = true;
    }

    function resetKeyboard() {
        root.showKeyboardOsd = true;
        root.keyboardOsdTimeout = 1500;
    }

    function resetPrivacy() {
        root.privacyEnabled = true;
        root.privacyMicrophoneEnabled = true;
        root.privacyScreenEnabled = true;
        root.privacyShowCollapsed = true;
    }

    function resetAppearance() {
        root.backgroundOpacity = 100;
        root.cornerRadius = 17;
        root.borderVisible = true;
        root.borderWidth = 1;
        root.fontFamily = "JetBrainsMono Nerd Font Mono";
        root.fontSize = 11;
        root.uiScale = 100;
    }

    function applyDefaults() {
        root.loading = true;
        root.settingsPage = 0;
        root.expansionMode = "hover";
        root.animationDuration = 220;
        root.showKeyboardOsd = true;
        root.keyboardOsdTimeout = 1500;
        root.volumeStep = 2;
        root.volumeOsdTimeout = 1500;
        root.brightnessOsdTimeout = 1500;
        root.ddcSyncEnabled = true;
        root.ddcSyncInterval = 5000;
        root.showNetworkName = true;
        root.showCpuStat = true;
        root.showRamStat = true;
        root.showTempStat = true;
        root.showBatteryStat = true;
        root.showMediaArtwork = true;
        root.showMediaProgress = true;
        root.mediaOsdTimeout = 4000;
        root.notificationOsdTimeout = 6000;
        root.notificationHistoryLimit = 50;
        root.showNotificationImages = true;
        root.showBluetoothStatus = true;
        root.privacyEnabled = true;
        root.privacyMicrophoneEnabled = true;
        root.privacyScreenEnabled = true;
        root.privacyShowCollapsed = true;
        root.backgroundOpacity = 100;
        root.cornerRadius = 17;
        root.borderVisible = true;
        root.borderWidth = 1;
        root.fontFamily = "JetBrainsMono Nerd Font Mono";
        root.fontSize = 11;
        root.uiScale = 100;
        root.workspaceVisibility = "all";
        root.showOccupiedIndicator = true;
        root.includeUrgentWorkspaces = true;
        root.collapsedItems = ["time"];
        root.collapsedItemSpacing = 4;
        root.collapsedPadding = 14;
        root.showWorkspaceTags = true;
        root.showWindowInfo = true;
        root.showSystemStats = true;
        root.showMedia = true;
        root.showVolume = true;
        root.showBrightness = true;
        root.showExternalBrightness = true;
        root.showNotifications = true;
        root.cpuRefreshInterval = 300;
        root.batteryWarningThreshold = 20;
        root.batteryCriticalThreshold = 10;
        root.loading = false;
        root.initialized = true;
    }

    function loadFromText(text) {
        root.loading = true;
        if (!text || text.trim().length === 0) {
            root.settingsPage = 0;
            root.expansionMode = "hover";
            root.animationDuration = 220;
            root.lastError = "Settings file is empty; using defaults";
        } else {
            try {
                const parsed = JSON.parse(text);
                const version = Number(parsed.version) || 1;
                const rawPage = Number(parsed.settingsPage) || 0;
                let migratedPage = rawPage;
                if (version < 2) {
                    migratedPage = rawPage + 5;
                } else if (version < 3) {
                    migratedPage = rawPage === 0 ? 0 : rawPage + 4;
                } else if (version < 5) {
                    migratedPage = rawPage <= 1 ? rawPage : rawPage + 3;
                } else if (version < 6) {
                    migratedPage = rawPage <= 2 ? rawPage : rawPage + 2;
                } else if (version < 10) {
                    migratedPage = rawPage <= 3 ? rawPage : rawPage + 1;
                }
                if (version < 15 && migratedPage >= 5)
                    migratedPage += 1;
                if (version < 19 && migratedPage >= 6)
                    migratedPage += 1;
                root.settingsPage = root.clampPage(migratedPage);
                root.expansionMode = parsed.expansionMode === "click" || parsed.expansionMode === "hover"
                    ? parsed.expansionMode
                    : (parsed.hoverExpansion === false ? "click" : "hover");
                root.animationDuration = root.clampAnimationDuration(parsed.animationDuration);
                root.backgroundOpacity = root.clampBackgroundOpacity(parsed.backgroundOpacity);
                root.cornerRadius = root.clampCornerRadius(parsed.cornerRadius);
                root.borderVisible = parsed.borderVisible === undefined ? true : !!parsed.borderVisible;
                root.borderWidth = root.clampBorderWidth(parsed.borderWidth);
                root.fontFamily = root.clampFontFamily(parsed.fontFamily);
                root.fontSize = parsed.fontSize !== undefined
                    ? Math.max(9, Math.min(13, Math.round(Number(parsed.fontSize))))
                    : (parsed.fontScale !== undefined
                        ? Math.max(9, Math.min(13, Math.round(Number(parsed.fontScale) * 11 / 100)))
                        : 11);
                root.uiScale = parsed.uiScale === undefined
                    ? 100
                    : Math.max(85, Math.min(115, Math.round(Number(parsed.uiScale) / 5) * 5));
                root.workspaceVisibility = root.clampWorkspaceVisibility(parsed.workspaceVisibility);
                root.showOccupiedIndicator = parsed.showOccupiedIndicator === undefined ? true : !!parsed.showOccupiedIndicator;
                root.includeUrgentWorkspaces = parsed.includeUrgentWorkspaces === undefined ? true : !!parsed.includeUrgentWorkspaces;
                root.collapsedItems = root.sanitizeCollapsedItems(parsed.collapsedItems);
                root.collapsedItemSpacing = root.clampCollapsedItemSpacing(parsed.collapsedItemSpacing);
                root.collapsedPadding = root.clampCollapsedPadding(parsed.collapsedPadding);
                root.showWorkspaceTags = parsed.showWorkspaceTags === undefined ? true : !!parsed.showWorkspaceTags;
                root.showWindowInfo = parsed.showWindowInfo === undefined ? true : !!parsed.showWindowInfo;
                root.showSystemStats = parsed.showSystemStats === undefined ? true : !!parsed.showSystemStats;
                root.showMedia = parsed.showMedia === undefined ? true : !!parsed.showMedia;
                root.showVolume = parsed.showVolume === undefined ? true : !!parsed.showVolume;
                root.showBrightness = parsed.showBrightness === undefined ? true : !!parsed.showBrightness;
                root.showExternalBrightness = parsed.showExternalBrightness === undefined ? true : !!parsed.showExternalBrightness;
                root.showNotifications = parsed.showNotifications === undefined ? true : !!parsed.showNotifications;
                root.cpuRefreshInterval = root.clampCpuRefreshInterval(parsed.cpuRefreshInterval);
                root.batteryWarningThreshold = root.clampBatteryWarning(parsed.batteryWarningThreshold);
                root.batteryCriticalThreshold = root.clampBatteryCritical(parsed.batteryCriticalThreshold);
                root.showKeyboardOsd = parsed.showKeyboardOsd === undefined ? true : !!parsed.showKeyboardOsd;
                root.keyboardOsdTimeout = root.clampKeyboardOsdTimeout(parsed.keyboardOsdTimeout);
                root.volumeStep = root.clampVolumeStep(parsed.volumeStep);
                root.volumeOsdTimeout = root.clampOsdTimeout(parsed.volumeOsdTimeout);
                root.brightnessOsdTimeout = root.clampOsdTimeout(parsed.brightnessOsdTimeout);
                root.ddcSyncEnabled = parsed.ddcSyncEnabled === undefined ? true : !!parsed.ddcSyncEnabled;
                root.ddcSyncInterval = root.clampDdcSyncInterval(parsed.ddcSyncInterval);
                root.showNetworkName = parsed.showNetworkName === undefined ? true : !!parsed.showNetworkName;
                root.showCpuStat = parsed.showCpuStat === undefined ? true : !!parsed.showCpuStat;
                root.showRamStat = parsed.showRamStat === undefined ? true : !!parsed.showRamStat;
                root.showTempStat = parsed.showTempStat === undefined ? true : !!parsed.showTempStat;
                root.showBatteryStat = parsed.showBatteryStat === undefined ? true : !!parsed.showBatteryStat;
                root.showMediaArtwork = parsed.showMediaArtwork === undefined ? true : !!parsed.showMediaArtwork;
                root.showMediaProgress = parsed.showMediaProgress === undefined ? true : !!parsed.showMediaProgress;
                root.mediaOsdTimeout = root.clampMediaOsdTimeout(parsed.mediaOsdTimeout);
                root.notificationOsdTimeout = root.clampNotificationOsdTimeout(parsed.notificationOsdTimeout);
                root.notificationHistoryLimit = root.clampNotificationHistoryLimit(parsed.notificationHistoryLimit);
                root.showNotificationImages = parsed.showNotificationImages === undefined ? true : !!parsed.showNotificationImages;
                root.showBluetoothStatus = parsed.showBluetoothStatus === undefined ? true : !!parsed.showBluetoothStatus;
                root.privacyEnabled = parsed.privacyEnabled === undefined ? true : !!parsed.privacyEnabled;
                root.privacyMicrophoneEnabled = parsed.privacyMicrophoneEnabled === undefined ? true : !!parsed.privacyMicrophoneEnabled;
                root.privacyScreenEnabled = parsed.privacyScreenEnabled === undefined ? true : !!parsed.privacyScreenEnabled;
                root.privacyShowCollapsed = parsed.privacyShowCollapsed === undefined ? true : !!parsed.privacyShowCollapsed;
                if (root.batteryCriticalThreshold > root.batteryWarningThreshold)
                    root.batteryCriticalThreshold = root.batteryWarningThreshold;
                root.lastError = "";
            } catch (error) {
                root.settingsPage = 0;
                root.expansionMode = "hover";
                root.animationDuration = 220;
                root.lastError = "Malformed settings; using defaults";
            }
        }
        root.loading = false;
        root.initialized = true;
    }

    function snapshot() {
        return {
            "version": 21,
            "settingsPage": root.settingsPage,
            "expansionMode": root.expansionMode,
            "animationDuration": root.animationDuration,
            "showKeyboardOsd": root.showKeyboardOsd,
            "keyboardOsdTimeout": root.keyboardOsdTimeout,
            "volumeStep": root.volumeStep,
            "volumeOsdTimeout": root.volumeOsdTimeout,
            "brightnessOsdTimeout": root.brightnessOsdTimeout,
            "ddcSyncEnabled": root.ddcSyncEnabled,
            "ddcSyncInterval": root.ddcSyncInterval,
            "showNetworkName": root.showNetworkName,
            "backgroundOpacity": root.backgroundOpacity,
            "cornerRadius": root.cornerRadius,
            "borderVisible": root.borderVisible,
            "borderWidth": root.borderWidth,
            "fontFamily": root.fontFamily,
            "fontSize": root.fontSize,
            "uiScale": root.uiScale,
            "workspaceVisibility": root.workspaceVisibility,
            "showOccupiedIndicator": root.showOccupiedIndicator,
            "includeUrgentWorkspaces": root.includeUrgentWorkspaces,
            "collapsedItems": root.collapsedItems,
            "collapsedItemSpacing": root.collapsedItemSpacing,
            "collapsedPadding": root.collapsedPadding,
            "showWorkspaceTags": root.showWorkspaceTags,
            "showWindowInfo": root.showWindowInfo,
            "showSystemStats": root.showSystemStats,
            "showMedia": root.showMedia,
            "showVolume": root.showVolume,
            "showBrightness": root.showBrightness,
            "showExternalBrightness": root.showExternalBrightness,
            "showNotifications": root.showNotifications,
            "showCpuStat": root.showCpuStat,
            "showRamStat": root.showRamStat,
            "showTempStat": root.showTempStat,
            "showBatteryStat": root.showBatteryStat,
            "showMediaArtwork": root.showMediaArtwork,
            "showMediaProgress": root.showMediaProgress,
            "mediaOsdTimeout": root.mediaOsdTimeout,
            "notificationOsdTimeout": root.notificationOsdTimeout,
            "notificationHistoryLimit": root.notificationHistoryLimit,
            "showNotificationImages": root.showNotificationImages,
            "showBluetoothStatus": root.showBluetoothStatus,
            "privacyEnabled": root.privacyEnabled,
            "privacyMicrophoneEnabled": root.privacyMicrophoneEnabled,
            "privacyScreenEnabled": root.privacyScreenEnabled,
            "privacyShowCollapsed": root.privacyShowCollapsed,
            "cpuRefreshInterval": root.cpuRefreshInterval,
            "batteryWarningThreshold": root.batteryWarningThreshold,
            "batteryCriticalThreshold": root.batteryCriticalThreshold
        };
    }

    function save() {
        if (!root.initialized)
            return;
        settingsFile.setText(JSON.stringify(root.snapshot(), null, 2) + "\n");
    }

    function flush() {
        saveTimer.stop();
        root.save();
    }

    function refresh() {
        mkdirProcess.running = true;
    }

    onSettingsPageChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onExpansionModeChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onAnimationDurationChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onBackgroundOpacityChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onCornerRadiusChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onBorderVisibleChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onBorderWidthChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onFontFamilyChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onFontSizeChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onUiScaleChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onWorkspaceVisibilityChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowOccupiedIndicatorChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onIncludeUrgentWorkspacesChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onCollapsedItemsChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onCollapsedItemSpacingChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onCollapsedPaddingChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowWorkspaceTagsChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowWindowInfoChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowSystemStatsChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowMediaChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowVolumeChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowBrightnessChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowExternalBrightnessChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowKeyboardOsdChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowNotificationsChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onKeyboardOsdTimeoutChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onVolumeStepChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onVolumeOsdTimeoutChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onBrightnessOsdTimeoutChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onDdcSyncEnabledChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onDdcSyncIntervalChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowNetworkNameChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowCpuStatChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowRamStatChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowTempStatChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowBatteryStatChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowMediaArtworkChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowMediaProgressChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onMediaOsdTimeoutChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onNotificationOsdTimeoutChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onNotificationHistoryLimitChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowNotificationImagesChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onShowBluetoothStatusChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onPrivacyEnabledChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onPrivacyMicrophoneEnabledChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onPrivacyScreenEnabledChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onPrivacyShowCollapsedChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onCpuRefreshIntervalChanged: {
        if (root.initialized && !root.loading && !saveTimer.running)
            saveTimer.restart();
    }

    onBatteryWarningThresholdChanged: {
        if (root.initialized && !root.loading) {
            if (root.batteryCriticalThreshold > root.batteryWarningThreshold)
                root.batteryCriticalThreshold = root.batteryWarningThreshold;
            if (!saveTimer.running)
                saveTimer.restart();
        }
    }

    onBatteryCriticalThresholdChanged: {
        if (root.initialized && !root.loading) {
            if (root.batteryCriticalThreshold > root.batteryWarningThreshold)
                root.batteryWarningThreshold = root.batteryCriticalThreshold;
            if (!saveTimer.running)
                saveTimer.restart();
        }
    }

    Component.onCompleted: root.refresh()

    Process {
        id: mkdirProcess
        command: ["mkdir", "-p", root.configDir]

        onExited: migrateProcess.running = true
    }

    // Copy legacy settings into the new location without removing the original.
    Process {
        id: migrateProcess
        command: [
            "sh", "-c",
            "if [ -f \"$1\" ] && [ ! -e \"$2\" ]; then cp -- \"$1\" \"$2\"; fi",
            "maneso-migrate", root.legacyConfigPath, root.configPath
        ]

        onExited: settingsFile.reload()
    }

    FileView {
        id: settingsFile
        path: root.configPath
        atomicWrites: true
        watchChanges: false
        printErrors: false

        onLoaded: root.loadFromText(text())
        onLoadFailed: {
            root.lastError = "Settings file not found; using defaults";
            root.applyDefaults();
        }
        onSaved: root.lastError = ""
        onSaveFailed: error => root.lastError = FileViewError.toString(error)
    }

    Timer {
        id: saveTimer
        interval: 300
        onTriggered: root.save()
    }
}
