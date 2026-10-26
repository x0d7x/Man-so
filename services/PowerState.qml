import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property string profile: "unknown"
    property bool changing: false
    property string pendingProfile: ""
    property string lastError: ""

    readonly property bool busy: root.changing

    readonly property string label: {
        if (root.profile === "performance")
            return "PERF";
        if (root.profile === "balanced")
            return "BAL";
        if (root.profile === "power-saver")
            return "SAVE";
        return "TLP";
    }
    readonly property string icon: {
        if (root.profile === "performance")
            return "";
        if (root.profile === "balanced")
            return "";
        if (root.profile === "power-saver")
            return "";
        return "󰓅";
    }

    function refresh() {
        if (!statusProcess.running)
            statusProcess.running = true;
    }

    function profileName(text) {
        const value = text.trim();
        if (value === "performance" || value === "balanced" || value === "power-saver")
            return value;
        return "unknown";
    }

    function cycle() {
        const order = ["performance", "balanced", "power-saver"];
        const index = order.indexOf(root.profile);
        const next = order[(index + 1 + order.length) % order.length];
        root.setProfile(next);
    }

    function setProfile(name) {
        if (root.changing) {
            root.pendingProfile = name;
            return;
        }

        root.changing = true;
        root.lastError = "";
        setProcess.command = ["tlpctl", name];
        setProcess.running = true;
    }

    Process {
        id: statusProcess
        command: ["tlpctl", "get"]

        stdout: StdioCollector {
            onStreamFinished: root.profile = root.profileName(this.text)
        }
    }

    Process {
        id: setProcess

        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.trim().length > 0 && this.text.indexOf("Error") !== -1)
                    root.lastError = this.text.trim();
            }
        }

        onExited: exitCode => {
            root.changing = false;
            if (root.pendingProfile.length > 0) {
                const next = root.pendingProfile;
                root.pendingProfile = "";
                root.setProfile(next);
                return;
            }
            if (exitCode !== 0)
                root.lastError = "TLP command failed";
            root.refresh();
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
