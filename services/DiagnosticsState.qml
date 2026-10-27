import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property string quickshellVersion: ""
    property string mangoVersion: ""
    property string osName: ""
    property string kernelVersion: ""
    property string keyboardLayout: ""
    property string missingTools: ""
    property string backlightDevices: ""
    property string mpdSocket: "/tmp/mpd_socket"

    readonly property string monitorsText: Quickshell.screens.map(screen =>
        screen.name + " " + screen.width + "×" + screen.height
        + " @" + screen.devicePixelRatio + "x").join(", ")
    readonly property string toolStatus: root.missingTools.length === 0
        ? "All required tools available"
        : "Missing: " + root.missingTools
    readonly property string backlightStatus: root.backlightDevices.length === 0
        ? "None detected"
        : root.backlightDevices

    function parseVersion(text) {
        const match = text.match(/Quickshell\s+([^\s]+)/);
        return match ? match[1] : text.trim().split("\n")[0];
    }

    function parseJson(text) {
        try {
            return JSON.parse(text);
        } catch (error) {
            return null;
        }
    }

    function parseOsName(text) {
        const lines = text.split("\n");
        for (let i = 0; i < lines.length; ++i) {
            if (lines[i].indexOf("PRETTY_NAME=") === 0) {
                return lines[i].substring("PRETTY_NAME=".length).replace(/^"|"$/g, "");
            }
        }
        return "";
    }

    function refresh() {
        if (!quickshellVersionProcess.running)
            quickshellVersionProcess.running = true;
        if (!mangoVersionProcess.running)
            mangoVersionProcess.running = true;
        if (!kernelProcess.running)
            kernelProcess.running = true;
        if (!keyboardLayoutProcess.running)
            keyboardLayoutProcess.running = true;
        if (!toolsProcess.running)
            toolsProcess.running = true;
        if (!backlightProcess.running)
            backlightProcess.running = true;
        osFile.reload();
    }

    FileView {
        id: osFile
        path: "/etc/os-release"
        onTextChanged: root.osName = root.parseOsName(osFile.text())
    }

    Process {
        id: quickshellVersionProcess
        command: ["qs", "--version"]
        stdout: StdioCollector {
            onStreamFinished: root.quickshellVersion = root.parseVersion(this.text)
        }
    }

    Process {
        id: mangoVersionProcess
        command: ["mmsg", "get", "version"]
        stdout: StdioCollector {
            onStreamFinished: {
                const data = root.parseJson(this.text);
                if (data && data.version)
                    root.mangoVersion = data.version;
            }
        }
    }

    Process {
        id: kernelProcess
        command: ["uname", "-r"]
        stdout: StdioCollector {
            onStreamFinished: root.kernelVersion = this.text.trim()
        }
    }

    Process {
        id: keyboardLayoutProcess
        command: ["mmsg", "get", "keyboardlayout"]
        stdout: StdioCollector {
            onStreamFinished: {
                const data = root.parseJson(this.text);
                if (data && data.layout)
                    root.keyboardLayout = data.layout;
            }
        }
    }

    Process {
        id: toolsProcess
        command: [
            "sh", "-c",
            "for c in ddcutil brightnessctl ncat ffmpeg pactl wpctl notify-send; do command -v \"$c\" >/dev/null || printf '%s ' \"$c\"; done"
        ]
        stdout: StdioCollector {
            onStreamFinished: root.missingTools = this.text.trim()
        }
    }

    Process {
        id: backlightProcess
        command: [
            "sh", "-c",
            "for d in /sys/class/backlight/*; do [ -d \"$d\" ] && basename \"$d\"; done"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                root.backlightDevices = this.text.trim().split("\n").filter(line => line.length > 0).join(", ");
            }
        }
    }

    Component.onCompleted: root.refresh()
}
