import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property int settingsPage: 0
    property bool hoverExpansion: true
    property int animationDuration: 220
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
    property bool showNotifications: true
    property int cpuRefreshInterval: 300
    property int batteryWarningThreshold: 20
    property int batteryCriticalThreshold: 10
    property int fontSize: 11
    property bool initialized: false
    property bool loading: false
    property string lastError: ""

    readonly property string configDir: {
        const xdg = Quickshell.env("XDG_CONFIG_HOME");
        const base = xdg && xdg.length > 0
            ? xdg
            : Quickshell.env("HOME") + "/.config";
        return base + "/man-qs";
    }
    readonly property string configPath: root.configDir + "/settings.json"

    function clampPage(value) {
        const page = Number(value);
        if (!Number.isFinite(page))
            return 0;
        return Math.max(0, Math.min(5, Math.round(page)));
    }

    function clampAnimationDuration(value) {
        const duration = Number(value);
        if (!Number.isFinite(duration))
            return 220;
        return Math.max(80, Math.min(600, Math.round(duration / 10) * 10));
    }

    function resetGeneral() {
        root.hoverExpansion = true;
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
        root.showNotifications = true;
    }

    function resetAppearance() {
        root.backgroundOpacity = 100;
        root.cornerRadius = 17;
        root.borderVisible = true;
        root.borderWidth = 1;
        root.fontFamily = "JetBrainsMono Nerd Font Mono";
        root.fontSize = 11;
    }

    function applyDefaults() {
        root.loading = true;
        root.settingsPage = 0;
        root.hoverExpansion = true;
        root.animationDuration = 220;
        root.backgroundOpacity = 100;
        root.cornerRadius = 17;
        root.borderVisible = true;
        root.borderWidth = 1;
        root.fontFamily = "JetBrainsMono Nerd Font Mono";
        root.fontSize = 11;
        root.showWorkspaceTags = true;
        root.showWindowInfo = true;
        root.showSystemStats = true;
        root.showMedia = true;
        root.showVolume = true;
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
            root.hoverExpansion = true;
            root.animationDuration = 220;
            root.lastError = "Settings file is empty; using defaults";
        } else {
            try {
                const parsed = JSON.parse(text);
                const version = Number(parsed.version) || 1;
                const rawPage = Number(parsed.settingsPage) || 0;
                if (version < 2) {
                    root.settingsPage = root.clampPage(rawPage + 4);
                } else if (version < 3) {
                    root.settingsPage = root.clampPage(rawPage === 0 ? 0 : rawPage + 3);
                } else if (version < 5) {
                    root.settingsPage = root.clampPage(rawPage <= 1 ? rawPage : rawPage + 2);
                } else if (version < 6) {
                    root.settingsPage = root.clampPage(rawPage <= 2 ? rawPage : rawPage + 1);
                } else {
                    root.settingsPage = root.clampPage(rawPage);
                }
                root.hoverExpansion = parsed.hoverExpansion === undefined ? true : !!parsed.hoverExpansion;
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
                root.showWorkspaceTags = parsed.showWorkspaceTags === undefined ? true : !!parsed.showWorkspaceTags;
                root.showWindowInfo = parsed.showWindowInfo === undefined ? true : !!parsed.showWindowInfo;
                root.showSystemStats = parsed.showSystemStats === undefined ? true : !!parsed.showSystemStats;
                root.showMedia = parsed.showMedia === undefined ? true : !!parsed.showMedia;
                root.showVolume = parsed.showVolume === undefined ? true : !!parsed.showVolume;
                root.showNotifications = parsed.showNotifications === undefined ? true : !!parsed.showNotifications;
                root.cpuRefreshInterval = root.clampCpuRefreshInterval(parsed.cpuRefreshInterval);
                root.batteryWarningThreshold = root.clampBatteryWarning(parsed.batteryWarningThreshold);
                root.batteryCriticalThreshold = root.clampBatteryCritical(parsed.batteryCriticalThreshold);
                if (root.batteryCriticalThreshold > root.batteryWarningThreshold)
                    root.batteryCriticalThreshold = root.batteryWarningThreshold;
                root.lastError = "";
            } catch (error) {
                root.settingsPage = 0;
                root.hoverExpansion = true;
                root.animationDuration = 220;
                root.lastError = "Malformed settings; using defaults";
            }
        }
        root.loading = false;
        root.initialized = true;
    }

    function snapshot() {
        return {
            "version": 8,
            "settingsPage": root.settingsPage,
            "hoverExpansion": root.hoverExpansion,
            "animationDuration": root.animationDuration,
            "backgroundOpacity": root.backgroundOpacity,
            "cornerRadius": root.cornerRadius,
            "borderVisible": root.borderVisible,
            "borderWidth": root.borderWidth,
            "fontFamily": root.fontFamily,
            "fontSize": root.fontSize,
            "showWorkspaceTags": root.showWorkspaceTags,
            "showWindowInfo": root.showWindowInfo,
            "showSystemStats": root.showSystemStats,
            "showMedia": root.showMedia,
            "showVolume": root.showVolume,
            "showNotifications": root.showNotifications,
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

    onHoverExpansionChanged: {
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

    onShowNotificationsChanged: {
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
