import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property int level: -1
    property bool muted: false
    property bool visible: false
    property bool available: false
    property bool initialized: false
    property bool pendingShow: false
    property int step: 2
    property string deviceText: ""

    readonly property string levelText: root.level < 0 ? "--" : (root.muted ? "MUTE" : root.level + "%")
    readonly property real progress: root.level < 0 ? 0 : root.level / 100
    readonly property string icon: {
        if (!root.available || root.muted || root.level <= 0)
            return "󰖁";
        if (root.level < 34)
            return "󰕿";
        if (root.level < 67)
            return "󰖀";
        return "󰕾";
    }

    function clamp(value) {
        return Math.max(0, Math.min(100, value));
    }

    function show() {
        root.visible = true;
        hideTimer.restart();
    }

    function parseVolume(text) {
        const match = text.match(/Volume:\s*([0-9.]+)(\s*\[MUTED\])?/);
        if (!match) {
            root.available = false;
            root.visible = false;
            root.level = -1;
            return;
        }

        const value = Number.parseFloat(match[1]);
        if (!Number.isFinite(value)) {
            root.available = false;
            root.visible = false;
            return;
        }

        const nextLevel = Math.round(value * 100);
        const nextMuted = match[2] !== undefined;
        const changed = root.level !== nextLevel || root.muted !== nextMuted;
        const wasInitialized = root.initialized;

        root.level = nextLevel;
        root.muted = nextMuted;
        root.available = true;

        const description = text.match(/node\.description = "([^"]+)"/)
            || text.match(/alsa\.name = "([^"]+)"/)
            || text.match(/node\.nick = "([^"]+)"/);
        root.deviceText = description ? description[1] : "";

        if (wasInitialized && (root.pendingShow || changed))
            root.show();

        root.initialized = true;
        root.pendingShow = false;
    }

    function requestUpdate(showOsd) {
        if (showOsd)
            root.pendingShow = true;
        if (!queryTimer.running)
            queryTimer.restart();
    }

    function refresh() {
        if (!getVolume.running)
            getVolume.running = true;
    }

    function adjust(direction) {
        if (direction === 0 || !root.available)
            return;

        root.level = root.clamp(root.level + direction * root.step);
        if (direction > 0 && root.muted) {
            root.muted = false;
            Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_SINK@", "0"]);
        }

        root.show();
        Quickshell.execDetached([
            "wpctl", "set-volume", "-l", "1.0", "@DEFAULT_SINK@",
            root.step + "%" + (direction > 0 ? "+" : "-")
        ]);
    }

    function toggleMute() {
        if (!root.available)
            return;

        root.muted = !root.muted;
        root.show();
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_SINK@", "toggle"]);
    }

    function setLevel(percent) {
        if (!root.available)
            return;

        root.level = root.clamp(percent);
        root.muted = false;
        root.show();
        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_SINK@", root.level + "%"]);
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_SINK@", "0"]);
    }

    function handleEvent(line) {
        if (line.indexOf("on sink") === -1 && line.indexOf("on server") === -1)
            return;

        root.requestUpdate(true);
    }

    Component.onCompleted: root.requestUpdate(false)

    Process {
        id: subscribeProcess
        command: ["pactl", "subscribe"]
        running: true

        stdout: SplitParser {
            onRead: data => root.handleEvent(data)
        }

        onExited: restartSubscribe.restart()
    }

    Process {
        id: getVolume
        command: [
            "sh", "-c",
            "wpctl get-volume @DEFAULT_SINK@ 2>&1; wpctl inspect @DEFAULT_SINK@ 2>&1"
        ]

        stdout: StdioCollector {
            onStreamFinished: root.parseVolume(this.text)
        }
    }

    Timer {
        id: queryTimer
        interval: 60
        onTriggered: root.refresh()
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.visible = false
    }

    Timer {
        id: restartSubscribe
        interval: 500
        onTriggered: subscribeProcess.running = true
    }
}
