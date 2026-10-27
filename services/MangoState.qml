import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property var monitors: ({})
    property string focusedMonitor: ""
    property bool connected: false
    property var mangoIpc

    readonly property var focusedState: root.monitors[root.focusedMonitor] || null

    signal workspaceChanged(string monitor, var tags)
    signal layoutChanged(string monitor, string layout)
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
        const layoutChanges = [];

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
            if (before !== after) {
                changes.push({
                    "name": monitor.name,
                    "tags": monitor.active_tags || []
                });
            } else {
                const beforeLayout = previous.layout_symbol || "";
                const afterLayout = monitor.layout_symbol || "";
                if (afterLayout.length > 0 && beforeLayout !== afterLayout) {
                    layoutChanges.push({
                        "name": monitor.name,
                        "layout": afterLayout
                    });
                }
            }
        }

        root.monitors = next;

        let activeMonitor = "";
        for (let i = 0; i < data.monitors.length; ++i) {
            if (data.monitors[i] && data.monitors[i].active) {
                activeMonitor = data.monitors[i].name;
                break;
            }
        }

        if (activeMonitor.length > 0) {
            root.setFocusedMonitor(activeMonitor);
        } else if (!root.focusedMonitor || !next[root.focusedMonitor]) {
            const names = Object.keys(next);
            if (names.length > 0)
                root.setFocusedMonitor(names[0]);
        }

        for (let i = 0; i < changes.length; ++i)
            root.workspaceChanged(changes[i].name, changes[i].tags);

        for (let i = 0; i < layoutChanges.length; ++i)
            root.layoutChanged(layoutChanges[i].name, layoutChanges[i].layout);
    }

    function setFocusedMonitor(name) {
        if (!name || name === root.focusedMonitor)
            return;

        if (Object.keys(root.monitors).length > 0 && !root.monitors[name])
            return;

        root.focusedMonitor = name;
        root.monitorFocused(name);
    }

    function switchTag(index) {
        if (root.mangoIpc)
            root.mangoIpc.sendCommand("dispatch view," + index);
    }

    Connections {
        target: root.mangoIpc

        function onMonitorsLine(line) {
            root.consumeMonitors(line);
        }
    }
}
