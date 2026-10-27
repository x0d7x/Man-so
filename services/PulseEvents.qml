import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    signal event(string line)

    property bool connected: false

    Process {
        id: subscribeProcess
        command: ["pactl", "subscribe"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                root.connected = true;
                root.event(line);
            }
        }

        onExited: {
            root.connected = false;
            restartTimer.restart();
        }
    }

    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: subscribeProcess.running = true
    }
}
