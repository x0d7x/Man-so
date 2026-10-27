import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property int settingsPage: 0
    property bool hoverExpansion: true
    property int animationDuration: 220
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
        return Math.max(0, Math.min(2, Math.round(page)));
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

    function applyDefaults() {
        root.loading = true;
        root.settingsPage = 0;
        root.hoverExpansion = true;
        root.animationDuration = 220;
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
                root.settingsPage = version < 2 ? root.clampPage(rawPage + 1) : root.clampPage(rawPage);
                root.hoverExpansion = parsed.hoverExpansion === undefined ? true : !!parsed.hoverExpansion;
                root.animationDuration = root.clampAnimationDuration(parsed.animationDuration);
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
            "version": 2,
            "settingsPage": root.settingsPage,
            "hoverExpansion": root.hoverExpansion,
            "animationDuration": root.animationDuration
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
