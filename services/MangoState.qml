import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property var monitors: ({})
    property string focusedMonitor: ""
    property var focusedClient: null
    property bool connected: false

    readonly property var focusedState: root.monitors[root.focusedMonitor] || null

    signal workspaceChanged(string monitor, var tags)
    signal monitorFocused(string monitor)

    function parseJson(line) {
        if (!line || line.length === 0)
            return null;

        try {
            return JSON.parse(line);
        } catch (error) {
            return null;
        }
    }

    function consumeMonitors(line) {
        const data = root.parseJson(line);
        if (!data || !Array.isArray(data.monitors))
            return;

        root.connected = true;

        const next = {};
        const changes = [];

        for (let i = 0; i < data.monitors.length; ++i) {
            const monitor = data.monitors[i];
            if (!monitor || !monitor.name)
                continue;

            next[monitor.name] = monitor;

            const previous = root.monitors[monitor.name];
            if (!previous)
                continue;

            const before = JSON.stringify(previous.active_tags || []);
            const after = JSON.stringify(monitor.active_tags || []);
            if (before !== after)
                changes.push({
                    "name": monitor.name,
                    "tags": monitor.active_tags || []
                });
        }

        root.monitors = next;

        if (!root.focusedMonitor || !next[root.focusedMonitor]) {
            const names = Object.keys(next);
            if (names.length > 0)
                root.setFocusedMonitor(names[0]);
        }

        for (let i = 0; i < changes.length; ++i)
            root.workspaceChanged(changes[i].name, changes[i].tags);

        if (changes.length > 0)
            root.probeFocus();
    }

    function setFocusedMonitor(name) {
        if (!name || name === root.focusedMonitor)
            return;

        if (Object.keys(root.monitors).length > 0 && !root.monitors[name])
            return;

        root.focusedMonitor = name;
        root.monitorFocused(name);
    }

    function consumeFocusClient(line) {
        const data = root.parseJson(line);
        if (!data || !data.monitor)
            return;

        root.focusedClient = data;
        root.setFocusedMonitor(data.monitor);

        const monitor = root.monitors[data.monitor];
        if (!monitor)
            return;

        if (monitor.active_client && monitor.active_client.id === data.id)
            return;

        const update = Object.assign({}, monitor);
        update.active_client = data;

        const next = Object.assign({}, root.monitors);
        next[data.monitor] = update;
        root.monitors = next;
    }

    function consumeFocusSurface(line) {
        const data = root.parseJson(line);
        if (!data || !data.monitor)
            return;

        root.setFocusedMonitor(data.monitor);
    }

    function probeFocus() {
        if (!focusProbe.running)
            focusProbe.running = true;
    }

    function switchTag(index) {
        Quickshell.execDetached(["mmsg", "dispatch", "view," + index]);
    }

    Component.onCompleted: root.probeFocus()

    Process {
        id: allMonitorsProcess
        command: ["mmsg", "watch", "all-monitors"]
        running: true

        stdout: SplitParser {
            onRead: data => root.consumeMonitors(data)
        }

        onExited: {
            root.connected = false;
            restartMonitors.restart();
        }
    }

    Process {
        id: focusClientProcess
        command: ["mmsg", "watch", "focusing-client"]
        running: true

        stdout: SplitParser {
            onRead: data => root.consumeFocusClient(data)
        }

        onExited: restartFocusClient.restart()
    }

    Process {
        id: focusSurfaceProcess
        command: ["mmsg", "watch", "last_open_surface"]
        running: true

        stdout: SplitParser {
            onRead: data => root.consumeFocusSurface(data)
        }

        onExited: restartFocusSurface.restart()
    }

    Process {
        id: focusProbe
        command: ["mmsg", "get", "last_open_surface"]

        stdout: StdioCollector {
            onStreamFinished: root.consumeFocusSurface(this.text)
        }
    }

    Timer {
        id: restartMonitors
        interval: 1000
        onTriggered: allMonitorsProcess.running = true
    }

    Timer {
        id: restartFocusClient
        interval: 1000
        onTriggered: focusClientProcess.running = true
    }

    Timer {
        id: restartFocusSurface
        interval: 1000
        onTriggered: focusSurfaceProcess.running = true
    }
}
