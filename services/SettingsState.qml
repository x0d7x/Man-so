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
        return Math.max(0, Math.min(3, Math.round(page)));
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

    function resetAppearance() {
        root.backgroundOpacity = 100;
        root.cornerRadius = 17;
        root.borderVisible = true;
        root.borderWidth = 1;
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
                    root.settingsPage = root.clampPage(rawPage + 2);
                } else if (version < 3) {
                    root.settingsPage = root.clampPage(rawPage === 0 ? 0 : rawPage + 1);
                } else {
                    root.settingsPage = root.clampPage(rawPage);
                }
                root.hoverExpansion = parsed.hoverExpansion === undefined ? true : !!parsed.hoverExpansion;
                root.animationDuration = root.clampAnimationDuration(parsed.animationDuration);
                root.backgroundOpacity = root.clampBackgroundOpacity(parsed.backgroundOpacity);
                root.cornerRadius = root.clampCornerRadius(parsed.cornerRadius);
                root.borderVisible = parsed.borderVisible === undefined ? true : !!parsed.borderVisible;
                root.borderWidth = root.clampBorderWidth(parsed.borderWidth);
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
            "version": 3,
            "settingsPage": root.settingsPage,
            "hoverExpansion": root.hoverExpansion,
            "animationDuration": root.animationDuration,
            "backgroundOpacity": root.backgroundOpacity,
            "cornerRadius": root.cornerRadius,
            "borderVisible": root.borderVisible,
            "borderWidth": root.borderWidth
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
