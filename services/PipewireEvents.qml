import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    signal activityChanged()

    property bool enabled: true
    property bool currentNodeVideo: false

    function handleLine(line) {
        if (!root.enabled)
            return;

        const trimmed = line.trim();
        if (trimmed.indexOf("added:") === 0
            || trimmed.indexOf("removed:") === 0
            || trimmed.indexOf("changed:") === 0) {
            root.currentNodeVideo = false;
            if (trimmed.indexOf("removed:") === 0)
                root.activityChanged();
            return;
        }

        if (line.indexOf('media.class = "Stream/Input/Video"') !== -1
            || line.indexOf('media.class = "Video/Source"') !== -1) {
            root.currentNodeVideo = true;
            root.activityChanged();
            return;
        }

        if (root.currentNodeVideo && trimmed.indexOf("state:") === 0)
            root.activityChanged();
    }

    onEnabledChanged: {
        if (root.enabled) {
            restartTimer.stop();
            if (!monitorProcess.running)
                monitorProcess.running = true;
        } else {
            restartTimer.stop();
            monitorProcess.running = false;
        }
    }

    Process {
        id: monitorProcess
        command: ["pw-mon"]
        running: root.enabled

        stdout: SplitParser {
            onRead: line => root.handleLine(line)
        }

        onExited: {
            if (root.enabled)
                restartTimer.restart();
        }
    }

    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: {
            if (root.enabled)
                monitorProcess.running = true;
        }
    }
}
