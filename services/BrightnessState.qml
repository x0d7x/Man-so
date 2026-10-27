import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property string device: ""
    property int rawCurrent: -1
    property int maximum: -1
    property int percent: -1
    property int lastPercent: -1
    property bool initialized: false
    property bool available: false
    property bool visible: false
    property int osdTimeout: 1500
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

    function applyCurrent() {
        if (root.rawCurrent < 0 || root.maximum <= 0)
            return;

        const next = Math.max(0, Math.min(100, Math.round(root.rawCurrent * 100 / root.maximum)));
        const changed = root.lastPercent >= 0 && next !== root.lastPercent;
        root.percent = next;
        root.lastPercent = next;
        root.available = true;

        if (!root.initialized) {
            root.initialized = true;
            return;
        }

        if (changed)
            root.show();
    }

    function readCurrent(text) {
        const value = Number.parseInt(text.trim(), 10);
        if (!Number.isFinite(value))
            return;
        root.rawCurrent = value;
        root.applyCurrent();
    }

    function readMaximum(text) {
        const value = Number.parseInt(text.trim(), 10);
        if (!Number.isFinite(value) || value <= 0)
            return;
        root.maximum = value;
        root.applyCurrent();
    }

    function show() {
        root.visible = true;
        hideTimer.restart();
    }

    function setPercent(value, showOsd) {
        if (!root.available)
            return;

        const next = root.clamp(value);
        root.percent = next;
        root.lastPercent = next;
        root.pendingPercent = next;
        if (showOsd === undefined || showOsd)
            root.show();
        if (!writeProcess.running)
            writeTimer.restart();
    }

    function adjust(delta) {
        if (root.percent >= 0)
            root.setPercent(root.percent + delta);
    }

    function flushWrite() {
        if (writeProcess.running || root.pendingPercent < 0 || root.device.length === 0)
            return;

        const value = root.pendingPercent;
        root.pendingPercent = -1;
        writeProcess.command = ["brightnessctl", "-d", root.device, "set", value + "%"];
        writeProcess.running = true;
    }

    onOsdTimeoutChanged: {
        if (root.visible)
            hideTimer.restart();
    }

    Component.onCompleted: discoverProcess.running = true

    Process {
        id: discoverProcess
        command: [
            "sh", "-c",
            "for d in /sys/class/backlight/*; do [ -d \"$d\" ] || continue; basename \"$d\"; break; done"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const name = this.text.trim();
                if (name.length === 0) {
                    root.available = false;
                    return;
                }
                root.device = name;
                root.available = true;
                currentFile.path = "/sys/class/backlight/" + name + "/brightness";
                maximumFile.path = "/sys/class/backlight/" + name + "/max_brightness";
                currentFile.reload();
                maximumFile.reload();
            }
        }
    }

    FileView {
        id: currentFile
        path: ""
        watchChanges: false
        onTextChanged: root.readCurrent(currentFile.text())
        onLoadFailed: root.lastError = "Cannot read brightness"
    }

    FileView {
        id: maximumFile
        path: ""
        watchChanges: false
        onTextChanged: root.readMaximum(maximumFile.text())
        onLoadFailed: root.lastError = "Cannot read maximum brightness"
    }

    Process {
        id: udevProcess
        command: ["udevadm", "monitor", "--udev", "--subsystem-match=backlight"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                if (line.indexOf("backlight") !== -1) {
                    currentFile.reload();
                    maximumFile.reload();
                }
            }
        }

        onExited: udevRestart.restart()
    }

    Process {
        id: writeProcess

        onExited: {
            if (root.pendingPercent >= 0)
                writeTimer.restart();
            currentFile.reload();
        }
    }

    Timer {
        id: writeTimer
        interval: 80
        onTriggered: root.flushWrite()
    }

    Timer {
        id: hideTimer
        interval: root.osdTimeout
        onTriggered: root.visible = false
    }

    Timer {
        id: udevRestart
        interval: 1000
        onTriggered: udevProcess.running = true
    }
}
