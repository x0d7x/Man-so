import Quickshell
import Quickshell.Networking
import QtQuick

Scope {
    id: root

    property var pendingNetwork: null
    property string lastError: ""

    readonly property var device: {
        const devices = Networking.devices.values;

        for (let i = 0; i < devices.length; ++i) {
            if (devices[i].type === DeviceType.Wifi)
                return devices[i];
        }

        return null;
    }
    readonly property bool available: root.device !== null
    readonly property bool enabled: Networking.wifiEnabled
    readonly property var activeNetwork: {
        if (!root.device)
            return null;

        const networks = root.device.networks.values;
        for (let i = 0; i < networks.length; ++i) {
            if (networks[i].connected)
                return networks[i];
        }

        return null;
    }
    readonly property string activeSsid: root.activeNetwork ? root.activeNetwork.name : ""
    readonly property bool connected: root.activeNetwork !== null
    readonly property bool scanning: root.device ? root.device.scannerEnabled : false
    readonly property bool connecting: {
        if (root.pendingNetwork)
            return root.pendingNetwork.stateChanging;
        return root.activeNetwork ? root.activeNetwork.stateChanging : false;
    }
    readonly property var networks: {
        if (!root.device)
            return [];

        const list = root.device.networks.values.slice();
        list.sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            if (a.known !== b.known)
                return a.known ? -1 : 1;
            return b.signalStrength - a.signalStrength;
        });
        return list;
    }
    readonly property int activeSignal: {
        if (!root.activeNetwork)
            return 100;
        return Math.round(root.activeNetwork.signalStrength * 100);
    }
    readonly property string icon: {
        if (!root.available || !root.enabled)
            return "󰤮";
        if (!root.connected)
            return "󰤯";
        if (root.activeSignal >= 75)
            return "󰤨";
        if (root.activeSignal >= 50)
            return "󰤥";
        if (root.activeSignal >= 25)
            return "󰤢";
        return "󰤟";
    }
    readonly property string label: {
        if (!root.available)
            return "N/A";
        if (!root.enabled)
            return "OFF";
        if (root.connected)
            return root.activeSsid;
        return "ON";
    }

    function setScanning(value) {
        if (root.device)
            root.device.scannerEnabled = value;
    }

    function toggle() {
        root.lastError = "";
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function isOpen(network) {
        if (!network)
            return true;
        return network.security === WifiSecurityType.Open
            || network.security === WifiSecurityType.Owe
            || network.security === WifiSecurityType.Unknown;
    }

    function isEnterprise(network) {
        if (!network)
            return false;
        return network.security === WifiSecurityType.Wpa2Eap
            || network.security === WifiSecurityType.WpaEap;
    }

    function needsPassword(network) {
        if (!network || network.known)
            return false;
        return !root.isOpen(network) && !root.isEnterprise(network);
    }

    function connect(network, password) {
        if (!network || network.connected)
            return;

        root.lastError = "";
        root.pendingNetwork = network;

        if (root.needsPassword(network))
            network.connectWithPsk(password);
        else
            network.connect();
    }

    function connectWithPassword(network, password) {
        if (!network || password.length === 0)
            return;

        root.lastError = "";
        root.pendingNetwork = network;
        network.connectWithPsk(password);
    }

    function openEditor() {
        Quickshell.execDetached(["nm-connection-editor"]);
    }

    function clearError() {
        root.lastError = "";
    }

    Connections {
        target: root.pendingNetwork

        function onConnectionFailed(reason) {
            root.lastError = ConnectionFailReason.toString(reason);
        }
    }
}
