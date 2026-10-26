import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property bool busy: false
    property string lastError: ""
    property string promptMode: "none"
    property string promptPasskey: ""
    property string promptDeviceName: ""
    property string promptMessage: ""
    property var pairingDevice: null
    property int agentOffset: 0
    property string agentTail: ""
    property bool discoveryRequested: false

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: root.adapter !== null
    readonly property bool enabled: root.adapter ? root.adapter.enabled : false
    readonly property bool discovering: root.adapter ? root.adapter.discovering : false
    readonly property bool promptActive: root.promptMode !== "none"
    readonly property bool promptNeedsInput: root.promptMode === "enter" || root.promptMode === "pin"
    readonly property var connectedDevices: {
        if (!root.adapter || !root.adapter.devices)
            return [];
        return root.adapter.devices.values.filter(device => device && device.connected);
    }
    readonly property int connectedCount: root.connectedDevices.length
    readonly property var devices: {
        if (!root.adapter || !root.adapter.devices)
            return [];

        const list = root.adapter.devices.values.filter(device => device && !device.blocked);
        list.sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            if (a.paired !== b.paired)
                return a.paired ? -1 : 1;
            const aName = (a.name || a.address || "").toLowerCase();
            const bName = (b.name || b.address || "").toLowerCase();
            return aName.localeCompare(bName);
        });
        return list;
    }
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

    function stripAnsi(text) {
        return text.replace(/\u001b\[[0-9;?]*[A-Za-z]/g, "");
    }

    function writeAgent(value) {
        if (agentProcess.running)
            agentProcess.write(value + "\n");
    }

    function showPrompt(mode, passkey, message) {
        root.promptMode = mode;
        root.promptPasskey = passkey || "";
        root.promptMessage = message || "";
        root.promptDeviceName = root.pairingDevice
            ? (root.pairingDevice.name || root.pairingDevice.address || "Unknown device")
            : "Unknown device";
        root.agentTail = "";
    }

    function clearPrompt() {
        root.promptMode = "none";
        root.promptPasskey = "";
        root.promptMessage = "";
        root.promptDeviceName = "";
    }

    function processAgentText(text) {
        if (text.length < root.agentOffset)
            root.agentOffset = 0;

        const chunk = text.substring(root.agentOffset);
        root.agentOffset = text.length;
        if (chunk.length === 0)
            return;

        root.agentTail = (root.agentTail + root.stripAnsi(chunk)).replace(/\r/g, "\n");
        if (root.agentTail.length > 2000)
            root.agentTail = root.agentTail.slice(-1200);

        const output = root.agentTail;
        const confirm = output.match(/Confirm passkey\s+(\d+)/i);
        if (confirm) {
            root.showPrompt("confirm", confirm[1], "Confirm this passkey on both devices");
            return;
        }

        const enter = output.match(/Enter passkey[^\n]*/i);
        if (enter) {
            root.showPrompt("enter", "", "Enter the passkey shown on the other device");
            return;
        }

        const pin = output.match(/Enter PIN code[^\n]*/i);
        if (pin) {
            root.showPrompt("pin", "", "Enter the PIN shown on the other device");
            return;
        }

        const display = output.match(/Passkey:\s*(\d+)/i);
        if (display) {
            root.showPrompt("display", display[1], "Enter this passkey on the other device");
            return;
        }

        if (/Authorize service/i.test(output)) {
            root.showPrompt("authorize", "", "Authorize this device to use the service");
            return;
        }

        if (/Pairing successful|Device .* paired|Bonded:/i.test(output)) {
            root.lastError = "";
            root.clearPrompt();
            root.pairingDevice = null;
            return;
        }

        if (/Failed to pair|Pairing failed|AuthenticationFailed|AuthenticationRejected/i.test(output)) {
            root.lastError = "Pairing failed";
            root.clearPrompt();
            root.pairingDevice = null;
        }
    }

    function startAgent() {
        if (agentProcess.running)
            return;
        agentProcess.running = true;
    }

    function stopAgent() {
        if (!agentProcess.running)
            return;
        root.writeAgent("quit");
    }

    function startDiscovery() {
        root.discoveryRequested = true;
        root.lastError = "";
        if (root.adapter && root.adapter.enabled) {
            root.startAgent();
            root.adapter.discovering = true;
        }
    }

    function stopDiscovery() {
        root.discoveryRequested = false;
        if (root.adapter)
            root.adapter.discovering = false;
        if (!root.pairingDevice)
            root.stopAgent();
    }

    function setEnabled(value) {
        if (!root.adapter || root.busy)
            return;

        root.lastError = "";
        if (value) {
            if (root.adapter.state === BluetoothAdapterState.Blocked) {
                root.busy = true;
                unblockProcess.running = true;
                return;
            }
            root.adapter.enabled = true;
            root.adapter.pairable = true;
        } else {
            root.cancelPairing();
            root.clearPrompt();
            root.stopDiscovery();
            root.adapter.enabled = false;
        }
    }

    function toggle() {
        root.setEnabled(!root.enabled);
    }

    function activate(device) {
        if (!device)
            return;

        root.lastError = "";
        if (device.pairing)
            return;

        if (device.connected) {
            device.disconnect();
            return;
        }

        if (device.paired) {
            device.connect();
            return;
        }

        root.pairingDevice = device;
        root.clearPrompt();
        device.pair();
    }

    function acceptPrompt() {
        if (root.promptMode === "confirm" || root.promptMode === "authorize")
            root.writeAgent("yes");
        root.clearPrompt();
    }

    function rejectPrompt() {
        if (root.promptMode === "confirm" || root.promptMode === "authorize")
            root.writeAgent("no");
        if (root.pairingDevice)
            root.pairingDevice.cancelPair();
        root.clearPrompt();
    }

    function submitPasskey(value) {
        if (!/^\d{1,6}$/.test(value)) {
            root.lastError = "Passkey must be 1-6 digits";
            return;
        }

        root.writeAgent(value);
        root.clearPrompt();
    }

    function dismissPrompt() {
        root.clearPrompt();
    }

    function cancelPairing() {
        root.rejectPrompt();
        root.stopAgent();
        root.pairingDevice = null;
    }

    function openManager() {
        Quickshell.execDetached(["blueman-manager"]);
    }

    Process {
        id: agentProcess
        command: ["bluetoothctl", "--agent", "KeyboardDisplay"]
        stdinEnabled: true
        running: false

        stdout: StdioCollector {
            id: agentOut
            onDataChanged: root.processAgentText(agentOut.text)
        }

        onStarted: {
            root.writeAgent("default-agent");
            root.writeAgent("pairable on");
        }

        onExited: {
            root.agentOffset = 0;
            root.agentTail = "";
        }
    }

    Process {
        id: unblockProcess
        command: ["pkexec", "rfkill", "unblock", "bluetooth"]

        onExited: exitCode => {
            root.busy = false;
            if (exitCode === 0 && root.adapter) {
                root.adapter.enabled = true;
                root.adapter.pairable = true;
            } else {
                root.lastError = "Could not unblock Bluetooth";
            }
        }
    }

    Connections {
        target: root.pairingDevice

        function onPairedChanged() {
            if (root.pairingDevice && root.pairingDevice.paired) {
                root.lastError = "";
                root.clearPrompt();
                root.pairingDevice = null;
            }
        }
    }

    Connections {
        target: root.adapter

        function onStateChanged() {
            if (root.adapter.state !== BluetoothAdapterState.Enabling
                && root.adapter.state !== BluetoothAdapterState.Disabling)
                root.busy = false;
        }

        function onEnabledChanged() {
            if (root.adapter.enabled && root.discoveryRequested)
                root.startDiscovery();
        }
    }
}
