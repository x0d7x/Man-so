import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    signal activityChanged()

    property bool enabled: true
    property string currentBlock: ""
    property int currentId: -1
    property bool currentNodeVideo: false
    property var videoNodeIds: ({})

    function trigger() {
        if (root.enabled)
            root.activityChanged();
    }

    function handleLine(line) {
        if (!root.enabled)
            return;

        const trimmed = line.trim();
        if (trimmed === "added:" || trimmed === "removed:" || trimmed === "changed:") {
            root.currentBlock = trimmed.substring(0, trimmed.length - 1);
            root.currentId = -1;
            root.currentNodeVideo = false;
            return;
        }

        const idMatch = trimmed.match(/^id:\s*(\d+)/);
        if (idMatch) {
            root.currentId = Number.parseInt(idMatch[1], 10);
            if (root.currentBlock === "removed" && root.videoNodeIds[root.currentId]) {
                delete root.videoNodeIds[root.currentId];
                root.trigger();
            }
            return;
        }

        if (line.indexOf('media.class = "Stream/Input/Video"') !== -1
            || line.indexOf('media.class = "Video/Source"') !== -1) {
            root.currentNodeVideo = true;
            if (root.currentId >= 0)
                root.videoNodeIds[root.currentId] = true;
            root.trigger();
            return;
        }

        if (root.currentNodeVideo && trimmed.indexOf("state:") === 0)
            root.trigger();
    }

    onEnabledChanged: {
        root.videoNodeIds = ({});
        root.currentBlock = "";
        root.currentId = -1;
        root.currentNodeVideo = false;
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
