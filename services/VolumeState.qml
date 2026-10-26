import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property int level: -1
    property bool muted: false
    property bool visible: false
    property int step: 2

    readonly property string levelText: root.level < 0 ? "--" : root.level + "%"

    function parseVolume(text) {
        const match = text.match(/Volume:\s*([0-9.]+)(\s*\[MUTED\])?/);
        if (!match)
            return;

        const value = Number.parseFloat(match[1]);
        if (!Number.isFinite(value))
            return;

        root.level = Math.round(value * 100);
        root.muted = match[2] !== undefined;
    }

    function adjust(direction) {
        if (direction === 0)
            return;

        const sign = direction > 0 ? "+" : "-";
        if (root.level >= 0)
            root.level = Math.max(0, Math.min(100, root.level + direction * root.step));

        root.visible = true;
        hideTimer.restart();
        readTimer.restart();

        Quickshell.execDetached([
            "wpctl", "set-volume", "-l", "1.0", "@DEFAULT_SINK@",
            root.step + "%" + sign
        ]);
    }

    function refresh() {
        if (!getVolume.running)
            getVolume.running = true;
    }

    Component.onCompleted: root.refresh()

    Process {
        id: getVolume
        command: ["wpctl", "get-volume", "@DEFAULT_SINK@"]

        stdout: StdioCollector {
            onStreamFinished: root.parseVolume(this.text)
        }
    }

    Timer {
        id: hideTimer
        interval: 1200
        onTriggered: root.visible = false
    }

    Timer {
        id: readTimer
        interval: 100
        onTriggered: {
            if (getVolume.running)
                readTimer.restart();
            else
                getVolume.running = true;
        }
    }
}
