import Quickshell
import Quickshell.Io
import QtQuick

// Power actions for the island menu: lock, suspend, logout, reboot, shutdown.
// Destructive actions can require a confirmation, and suspend waits until the
// session lock reports secure so the machine never sleeps unlocked.
Scope {
    id: root

    property var settings
    property var lockScreen
    property var mangoIpc

    property string pendingAction: ""
    property bool busy: false
    property string lastError: ""
    property string afterLock: ""

    readonly property bool requireConfirm: root.settings ? root.settings.powerRequireConfirm : true

    readonly property var actions: [
        { "id": "lock", "label": "Lock", "icon": "󰌾", "description": "Lock the session now", "confirm": false },
        { "id": "suspend", "label": "Suspend", "icon": "󰤄", "description": "Lock, then suspend to RAM", "confirm": true },
        { "id": "logout", "label": "Logout", "icon": "󰍃", "description": "End the MangoWM session", "confirm": true },
        { "id": "reboot", "label": "Reboot", "icon": "󰑓", "description": "Restart the machine", "confirm": true },
        { "id": "shutdown", "label": "Shutdown", "icon": "󰐥", "description": "Power the machine off", "confirm": true }
    ]

    readonly property var visibleActions: {
        const result = [];
        for (let i = 0; i < root.actions.length; ++i) {
            if (root.enabled(root.actions[i].id))
                result.push(root.actions[i]);
        }
        return result;
    }

    function enabled(id) {
        if (!root.settings)
            return false;
        if (id === "lock")
            return root.settings.powerShowLock;
        if (id === "suspend")
            return root.settings.powerShowSuspend;
        if (id === "logout")
            return root.settings.powerShowLogout;
        if (id === "reboot")
            return root.settings.powerShowReboot;
        if (id === "shutdown")
            return root.settings.powerShowShutdown;
        return false;
    }

    function entry(id) {
        for (let i = 0; i < root.actions.length; ++i) {
            if (root.actions[i].id === id)
                return root.actions[i];
        }
        return null;
    }

    function request(id) {
        if (!root.enabled(id) || root.busy)
            return;
        const item = root.entry(id);
        if (!item)
            return;
        if (item.confirm && root.requireConfirm) {
            root.pendingAction = id;
            return;
        }
        root.run(id);
    }

    function confirm() {
        const id = root.pendingAction;
        root.pendingAction = "";
        if (id.length > 0)
            root.run(id);
    }

    function cancel() {
        root.pendingAction = "";
    }

    function run(id) {
        root.lastError = "";
        root.pendingAction = "";

        if (id === "lock") {
            if (root.lockScreen)
                root.lockScreen.lock();
            return;
        }

        if (id === "logout") {
            if (root.mangoIpc)
                root.mangoIpc.sendCommand("dispatch quit");
            return;
        }

        if (id === "suspend") {
            // Never suspend with an unlocked session.
            if (root.lockScreen && !root.lockScreen.secure) {
                root.afterLock = "suspend";
                root.lockScreen.lock();
                lockWaitTimer.restart();
                return;
            }
            root.runCommand(["systemctl", "suspend"]);
            return;
        }

        if (id === "reboot") {
            root.runCommand(["systemctl", "reboot"]);
            return;
        }

        if (id === "shutdown") {
            root.runCommand(["systemctl", "poweroff"]);
            return;
        }
    }

    function runCommand(command) {
        root.busy = true;
        actionProcess.command = command;
        actionProcess.running = true;
    }

    Connections {
        target: root.lockScreen

        function onSecureChanged() {
            if (root.lockScreen && root.lockScreen.secure && root.afterLock === "suspend") {
                root.afterLock = "";
                lockWaitTimer.stop();
                root.runCommand(["systemctl", "suspend"]);
            }
        }
    }

    // If the lock never reports secure, do not suspend: report instead.
    Timer {
        id: lockWaitTimer
        interval: 3000

        onTriggered: {
            if (root.afterLock.length === 0)
                return;
            root.afterLock = "";
            root.lastError = "Lock did not become secure; suspend cancelled";
        }
    }

    Process {
        id: actionProcess
        stderr: StdioCollector {
            id: actionError
        }

        onExited: exitCode => {
            root.busy = false;
            if (exitCode !== 0) {
                const detail = actionError.text.trim();
                root.lastError = "Action failed (exit " + exitCode + ")"
                    + (detail.length > 0 ? ": " + detail : "");
            }
        }
    }
}
