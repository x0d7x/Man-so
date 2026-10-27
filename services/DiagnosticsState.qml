import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property string quickshellVersion: ""
    property string mangoVersion: ""
    property string osName: ""
    property string kernelVersion: ""
    property string hostname: ""
    property string uptimeText: ""
    property string loadAverage: ""
    property string memoryText: ""
    property string keyboardLayout: ""
    property string missingTools: ""
    property string backlightDevices: ""
    property string audioStatus: ""
    property string networkStatus: ""
    property string notificationStatus: ""
    property string mpdStatus: ""
    property string ddcDisplay: ""
    property string ddcConnector: ""
    property int ddcPercent: -1
    property string mpdSocket: "/tmp/mpd_socket"

    readonly property string sessionText: (Quickshell.env("XDG_SESSION_TYPE") || "unknown")
        + " · " + (Quickshell.env("XDG_CURRENT_DESKTOP") || "unknown")
    readonly property string waylandDisplay: Quickshell.env("WAYLAND_DISPLAY") || "none"
    readonly property string monitorsText: Quickshell.screens.map(screen =>
        screen.name + " " + screen.width + "×" + screen.height
        + " @" + screen.devicePixelRatio + "x").join(", ")
    readonly property string toolStatus: root.missingTools.length === 0
        ? "All required tools available"
        : "Missing: " + root.missingTools
    readonly property string backlightStatus: root.backlightDevices.length === 0
        ? "None detected"
        : root.backlightDevices
    readonly property string ddcStatus: root.ddcDisplay.length === 0
        ? "Not detected"
        : (root.ddcConnector.length > 0 ? root.ddcConnector + " · " : "")
            + root.ddcDisplay + (root.ddcPercent >= 0 ? " · " + root.ddcPercent + "%" : "")
    readonly property string mpdSummary: root.mpdSocket + " · " + (root.mpdStatus.length > 0 ? root.mpdStatus : "unknown")

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
            if (lines[i].indexOf("PRETTY_NAME=") === 0)
                return lines[i].substring("PRETTY_NAME=".length).replace(/^"|"$/g, "");
        }
        return "";
    }

    function parseUptime(text) {
        const seconds = Number.parseFloat(text.trim().split(/\s+/)[0]);
        if (!Number.isFinite(seconds)) {
            root.uptimeText = "";
            return;
        }
        const days = Math.floor(seconds / 86400);
        const hours = Math.floor((seconds % 86400) / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        if (days > 0)
            root.uptimeText = days + "d " + hours + "h " + minutes + "m";
        else if (hours > 0)
            root.uptimeText = hours + "h " + minutes + "m";
        else
            root.uptimeText = minutes + "m";
    }

    function parseMemory(text) {
        let total = 0;
        let available = 0;
        const lines = text.split("\n");
        for (let i = 0; i < lines.length; ++i) {
            const match = lines[i].match(/^(MemTotal|MemAvailable):\s+(\d+)/);
            if (!match)
                continue;
            if (match[1] === "MemTotal")
                total = Number.parseInt(match[2], 10);
            else
                available = Number.parseInt(match[2], 10);
        }
        if (total <= 0) {
            root.memoryText = "";
            return;
        }
        const used = Math.max(0, total - available) / 1048576;
        const totalGiB = total / 1048576;
        root.memoryText = used.toFixed(1) + " / " + totalGiB.toFixed(1) + " GiB";
    }

    function parseAudio(text) {
        const description = text.match(/node\.description = "([^"]+)"/);
        const volume = text.match(/Volume:\s*([0-9.]+)(\s*\[MUTED\])?/);
        let result = description ? description[1] : "Unknown sink";
        if (volume) {
            result += " · " + Math.round(Number.parseFloat(volume[1]) * 100) + "%";
            if (volume[2])
                result += " muted";
        }
        root.audioStatus = result;
    }

    function parseNetwork(text) {
        const lines = text.split("\n");
        for (let i = 0; i < lines.length; ++i) {
            const match = lines[i].match(/^yes:(.*):(\d+)$/);
            if (match) {
                root.networkStatus = match[1] + " · " + match[2] + "%";
                return;
            }
        }
        root.networkStatus = "Disconnected";
    }

    function parseBacklight(text) {
        const values = [];
        const lines = text.split("\n");
        for (let i = 0; i < lines.length; ++i) {
            const match = lines[i].match(/^([^|]+)\|(\d+)\|(\d+)$/);
            if (!match)
                continue;
            const max = Number.parseInt(match[3], 10);
            const current = Number.parseInt(match[2], 10);
            const percent = max > 0 ? Math.round(current * 100 / max) : 0;
            values.push(match[1] + " · " + percent + "%");
        }
        root.backlightDevices = values.join(", ");
    }

    function parseDdcDetect(text) {
        const display = text.match(/^Display\s+\d+[\s\S]*?DRM connector:\s*(\S+)[\s\S]*?Monitor:\s*([^\n]+)/m);
        if (!display) {
            root.ddcDisplay = "";
            root.ddcConnector = "";
            return;
        }
        root.ddcConnector = display[1].trim();
        root.ddcDisplay = display[2].trim();
    }

    function parseDdcBrightness(text) {
        const match = text.match(/VCP\s+10\s+C\s+(\d+)\s+(\d+)/);
        if (!match) {
            root.ddcPercent = -1;
            return;
        }
        const current = Number.parseInt(match[1], 10);
        const max = Number.parseInt(match[2], 10);
        root.ddcPercent = max > 0 ? Math.round(current * 100 / max) : -1;
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
        if (!audioProcess.running)
            audioProcess.running = true;
        if (!networkProcess.running)
            networkProcess.running = true;
        if (!notificationProcess.running)
            notificationProcess.running = true;
        if (!mpdProcess.running)
            mpdProcess.running = true;
        if (!backlightProcess.running)
            backlightProcess.running = true;
        if (!ddcDetectProcess.running)
            ddcDetectProcess.running = true;
        if (!ddcBrightnessProcess.running)
            ddcBrightnessProcess.running = true;
        osFile.reload();
        hostnameFile.reload();
        uptimeFile.reload();
        loadFile.reload();
        memoryFile.reload();
    }

    FileView {
        id: osFile
        path: "/etc/os-release"
        onTextChanged: root.osName = root.parseOsName(osFile.text())
    }

    FileView {
        id: hostnameFile
        path: "/proc/sys/kernel/hostname"
        onTextChanged: root.hostname = hostnameFile.text().trim()
    }

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        onTextChanged: root.parseUptime(uptimeFile.text())
    }

    FileView {
        id: loadFile
        path: "/proc/loadavg"
        onTextChanged: root.loadAverage = loadFile.text().trim().split(/\s+/).slice(0, 3).join(" / ")
    }

    FileView {
        id: memoryFile
        path: "/proc/meminfo"
        onTextChanged: root.parseMemory(memoryFile.text())
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
            "for c in ddcutil brightnessctl ncat ffmpeg pactl wpctl notify-send nmcli; do command -v \"$c\" >/dev/null || printf '%s ' \"$c\"; done"
        ]
        stdout: StdioCollector {
            onStreamFinished: root.missingTools = this.text.trim()
        }
    }

    Process {
        id: audioProcess
        command: [
            "sh", "-c",
            "wpctl inspect @DEFAULT_SINK@ 2>/dev/null; wpctl get-volume @DEFAULT_SINK@ 2>/dev/null"
        ]
        stdout: StdioCollector {
            onStreamFinished: root.parseAudio(this.text)
        }
    }

    Process {
        id: networkProcess
        command: ["nmcli", "-t", "-f", "active,ssid,signal", "dev", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: root.parseNetwork(this.text)
        }
    }

    Process {
        id: notificationProcess
        command: [
            "sh", "-c",
            "if pgrep -x swaync >/dev/null; then printf 'swaync'; else printf 'Quickshell (swaync stopped)'; fi"
        ]
        stdout: StdioCollector {
            onStreamFinished: root.notificationStatus = this.text.trim()
        }
    }

    Process {
        id: mpdProcess
        command: [
            "sh", "-c",
            "if [ -S /tmp/mpd_socket ]; then printf 'present'; else printf 'missing'; fi"
        ]
        stdout: StdioCollector {
            onStreamFinished: root.mpdStatus = this.text.trim()
        }
    }

    Process {
        id: backlightProcess
        command: [
            "sh", "-c",
            "for d in /sys/class/backlight/*; do [ -d \"$d\" ] || continue; n=$(basename \"$d\"); c=$(cat \"$d/brightness\" 2>/dev/null); x=$(cat \"$d/max_brightness\" 2>/dev/null); [ -n \"$c\" ] && [ -n \"$x\" ] && printf '%s|%s|%s\\n' \"$n\" \"$c\" \"$x\"; done"
        ]
        stdout: StdioCollector {
            onStreamFinished: root.parseBacklight(this.text)
        }
    }

    Process {
        id: ddcDetectProcess
        command: ["sh", "-c", "ddcutil detect --brief 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.parseDdcDetect(this.text)
        }
    }

    Process {
        id: ddcBrightnessProcess
        command: ["sh", "-c", "ddcutil getvcp 10 --terse 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.parseDdcBrightness(this.text)
        }
    }

    Component.onCompleted: root.refresh()
}
