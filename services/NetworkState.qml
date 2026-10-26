import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property bool enabled: false
    property string activeSsid: ""
    property var networks: []
    property var savedNames: []
    property bool scanning: false
    property bool connecting: false
    property bool toggling: false
    property bool available: true

    readonly property bool connected: root.activeSsid.length > 0
    readonly property bool busy: root.scanning || root.connecting || root.toggling
    readonly property int activeSignal: {
        for (let i = 0; i < root.networks.length; ++i) {
            if (root.networks[i].ssid === root.activeSsid)
                return root.networks[i].signal;
        }
        return 100;
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

    function splitNmcli(line) {
        const fields = [];
        let current = "";
        let escaped = false;

        for (let i = 0; i < line.length; ++i) {
            const ch = line[i];
            if (escaped) {
                current += ch;
                escaped = false;
            } else if (ch === "\\") {
                escaped = true;
            } else if (ch === ":") {
                fields.push(current);
                current = "";
            } else {
                current += ch;
            }
        }

        fields.push(current);
        return fields;
    }

    function parseStatus(text) {
        const lines = text.split("\n");
        let section = "";
        let wifiEnabled = false;
        let active = "";
        const saved = [];

        for (let i = 0; i < lines.length; ++i) {
            const line = lines[i].trim();
            if (line === "__WIFI__") {
                section = "wifi";
                continue;
            }
            if (line === "__ACTIVE__") {
                section = "active";
                continue;
            }
            if (line === "__SAVED__") {
                section = "saved";
                continue;
            }
            if (line.length === 0)
                continue;

            if (section === "wifi") {
                wifiEnabled = line === "enabled";
            } else if (section === "active") {
                const fields = root.splitNmcli(line);
                if (fields.length >= 2 && fields[1] === "802-11-wireless" && fields[0].length > 0)
                    active = fields[0];
            } else if (section === "saved") {
                const fields = root.splitNmcli(line);
                if (fields.length >= 2 && fields[1] === "802-11-wireless" && fields[0].length > 0)
                    saved.push(fields[0]);
            }
        }

        root.enabled = wifiEnabled;
        root.available = wifiEnabled || saved.length > 0 || active.length > 0;
        root.savedNames = saved;
        root.activeSsid = wifiEnabled ? active : "";
    }

    function parseNetworks(text) {
        const result = [];
        const indexes = {};
        const lines = text.split("\n");

        for (let i = 0; i < lines.length; ++i) {
            const line = lines[i];
            if (line.length === 0)
                continue;

            const fields = root.splitNmcli(line);
            if (fields.length < 4)
                continue;

            const ssid = fields[1];
            if (ssid.length === 0)
                continue;

            const signal = Number.parseInt(fields[2], 10);
            const security = fields[3].trim();
            const item = {
                ssid: ssid,
                signal: Number.isFinite(signal) ? signal : 0,
                secure: security.length > 0 && security !== "--",
                security: security === "--" ? "" : security,
                inUse: fields[0].trim() === "*"
            };

            if (indexes[ssid] !== undefined) {
                const previous = result[indexes[ssid]];
                if (item.signal > previous.signal || item.inUse)
                    result[indexes[ssid]] = item;
                continue;
            }

            indexes[ssid] = result.length;
            result.push(item);
        }

        if (root.activeSsid.length > 0 && indexes[root.activeSsid] === undefined)
            result.unshift({ ssid: root.activeSsid, signal: 100, secure: true, security: "", inUse: true });

        result.sort((a, b) => (b.inUse ? 1 : 0) - (a.inUse ? 1 : 0) || b.signal - a.signal);
        root.networks = result;
    }

    function refreshStatus() {
        if (!statusProcess.running)
            statusProcess.running = true;
    }

    function scan() {
        if (!root.enabled || scanProcess.running)
            return;

        root.scanning = true;
        scanProcess.running = true;
    }

    function toggle() {
        if (root.toggling)
            return;

        const turnOn = !root.enabled;
        root.toggling = true;
        root.enabled = turnOn;
        if (!turnOn)
            root.activeSsid = "";

        toggleProcess.command = ["nmcli", "radio", "wifi", turnOn ? "on" : "off"];
        toggleProcess.running = true;
    }

    function isSaved(ssid) {
        return root.savedNames.indexOf(ssid) !== -1;
    }

    function connect(ssid, secure) {
        if (!root.enabled || ssid.length === 0)
            return;

        if (ssid === root.activeSsid)
            return;

        if (secure && !root.isSaved(ssid)) {
            Quickshell.execDetached([
                "foot", "-e", "sh", "-c",
                "nmcli --ask device wifi connect \"$1\"; printf '\\nPress Enter to close'; read",
                "sh", ssid
            ]);
            return;
        }

        root.connecting = true;
        connectProcess.command = ["nmcli", "device", "wifi", "connect", ssid];
        connectProcess.running = true;
    }

    function openEditor() {
        Quickshell.execDetached(["nm-connection-editor"]);
    }

    Process {
        id: statusProcess
        command: [
            "sh", "-c",
            "printf '__WIFI__\\n'; nmcli -t -f WIFI general 2>/dev/null; " +
            "printf '__ACTIVE__\\n'; nmcli -t -f NAME,TYPE connection show --active 2>/dev/null; " +
            "printf '__SAVED__\\n'; nmcli -t -f NAME,TYPE connection show 2>/dev/null"
        ]

        stdout: StdioCollector {
            onStreamFinished: root.parseStatus(this.text)
        }
    }

    Process {
        id: scanProcess
        command: [
            "nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY",
            "device", "wifi", "list", "--rescan", "yes"
        ]

        stdout: StdioCollector {
            onStreamFinished: root.parseNetworks(this.text)
        }

        onExited: {
            root.scanning = false;
            root.refreshStatus();
        }
    }

    Process {
        id: toggleProcess
        onExited: {
            root.toggling = false;
            root.refreshStatus();
            if (root.enabled)
                root.scan();
        }
    }

    Process {
        id: connectProcess
        onExited: {
            root.connecting = false;
            root.refreshStatus();
            if (root.enabled)
                root.scan();
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refreshStatus()
    }

    Component.onCompleted: root.refreshStatus()
}
