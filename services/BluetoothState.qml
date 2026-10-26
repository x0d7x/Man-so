import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick

Scope {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: root.adapter !== null
    readonly property bool enabled: root.adapter ? root.adapter.enabled : false
    readonly property var connectedDevices: {
        if (!root.adapter || !root.adapter.devices)
            return [];
        return root.adapter.devices.values.filter(device => device && device.connected);
    }
    readonly property int connectedCount: root.connectedDevices.length
    property bool busy: false
    readonly property string icon: root.enabled ? "󰂯" : "󰂲"
    readonly property string label: {
        if (!root.available)
            return "N/A";
        if (!root.enabled)
            return "OFF";
        if (root.connectedCount > 0)
            return root.connectedCount + " ON";
        return "ON";
    }

    function setEnabled(value) {
        if (root.busy)
            return;

        root.busy = true;
        if (value) {
            controlProcess.command = [
                "sh", "-c",
                "rfkill unblock bluetooth 2>/dev/null || pkexec rfkill unblock bluetooth; bluetoothctl power on"
            ];
        } else {
            controlProcess.command = ["bluetoothctl", "power", "off"];
        }
        controlProcess.running = true;
    }

    function toggle() {
        if (!root.adapter)
            return;
        root.setEnabled(!root.enabled);
    }

    function openManager() {
        Quickshell.execDetached(["blueman-manager"]);
    }

    Process {
        id: controlProcess
        onExited: root.busy = false
    }
}
