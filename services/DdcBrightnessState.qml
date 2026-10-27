import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property bool available: false
    property bool initialized: false
    property bool querying: false
    property int rawCurrent: -1
    property int maximum: -1
    property int percent: -1
    property int pendingPercent: -1
    property string lastError: ""

    readonly property string icon: {
        if (root.percent < 0)
            return "󰃞";
        if (root.percent < 30)
            return "󰃞";
        if (root.percent < 70)
            return "󰃟";
        return "󰃠";
    }
    readonly property string percentText: root.percent < 0 ? "--" : root.percent + "%"

    function clamp(value) {
        return Math.max(1, Math.min(100, Math.round(value)));
    }

    function parseReading(text) {
        const match = text.match(/VCP\s+10\s+C\s+(\d+)\s+(\d+)/);
        if (!match) {
            root.available = false;
            root.initialized = true;
            return;
        }

        const current = Number.parseInt(match[1], 10);
        const max = Number.parseInt(match[2], 10);
        if (!Number.isFinite(current) || !Number.isFinite(max) || max <= 0) {
            root.available = false;
            root.initialized = true;
            return;
        }

        root.rawCurrent = current;
        root.maximum = max;
        root.percent = Math.max(0, Math.min(100, Math.round(current * 100 / max)));
        root.available = true;
        root.initialized = true;
        root.lastError = "";
    }

    function query() {
        if (getProcess.running)
            return;
        root.querying = true;
        getProcess.running = true;
    }

    function setPercent(value) {
        if (!root.available || root.maximum <= 0)
            return;

        const next = root.clamp(value);
        root.percent = next;
        root.pendingPercent = next;
        if (!writeTimer.running)
            writeTimer.restart();
    }

    function flushWrite() {
        if (writeProcess.running || root.pendingPercent < 0 || root.maximum <= 0)
            return;

        const target = root.pendingPercent;
        root.pendingPercent = -1;
        const raw = Math.round(target * root.maximum / 100);
        writeProcess.command = ["ddcutil", "setvcp", "10", String(raw)];
        writeProcess.running = true;
    }

    Component.onCompleted: root.query()

    Process {
        id: getProcess
        command: ["ddcutil", "getvcp", "10", "--terse"]

        stdout: StdioCollector {
            onStreamFinished: root.parseReading(this.text)
        }

        onExited: {
            root.querying = false;
            if (root.percent < 0)
                root.available = false;
        }
    }

    Process {
        id: writeProcess

        onExited: {
            if (root.pendingPercent >= 0) {
                writeTimer.restart();
                return;
            }
            root.query();
        }
    }

    Timer {
        id: writeTimer
        interval: 180
        onTriggered: root.flushWrite()
    }
}
