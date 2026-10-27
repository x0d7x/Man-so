import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property var settings

    property real cpuRatio: -1
    property real memUsed: -1
    property real memTotal: -1
    property real memRatio: -1
    property real temperature: -1
    property real lastCpuTotal: -1
    property real lastCpuIdle: -1
    property string tempPath: ""
    property int batteryPercent: -1
    property string batteryStatus: ""

    readonly property string cpuText: root.cpuRatio < 0 ? "--" : Math.round(root.cpuRatio * 100) + "%"
    readonly property string memText: root.memTotal <= 0 ? "--" : root.memUsed.toFixed(1) + "/" + root.memTotal.toFixed(1) + "G"
    readonly property string tempText: root.temperature < 0 ? "--" : Math.round(root.temperature) + "°C"
    readonly property string batteryText: root.batteryPercent < 0 ? "--" : root.batteryPercent + "%"
    readonly property string batteryIcon: {
        if (root.batteryStatus === "Charging")
            return "󰂄";
        if (root.batteryPercent >= 90)
            return "󰂂";
        if (root.batteryPercent >= 70)
            return "󰂁";
        if (root.batteryPercent >= 50)
            return "󰂀";
        if (root.batteryPercent >= 30)
            return "󰁾";
        if (root.batteryPercent >= 10)
            return "󰁻";
        return "󰂎";
    }

    function readCpu(text) {
        const line = text.split("\n")[0];
        if (!line || line.indexOf("cpu") !== 0)
            return;

        const fields = line.trim().split(/\s+/);
        const values = [];
        for (let i = 1; i < fields.length; ++i)
            values.push(Number(fields[i]));

        if (values.length < 5)
            return;

        let total = 0;
        for (let i = 0; i < Math.min(8, values.length); ++i)
            total += values[i];

        const idle = values[3] + values[4];

        if (root.lastCpuTotal >= 0) {
            const totalDelta = total - root.lastCpuTotal;
            const idleDelta = idle - root.lastCpuIdle;
            if (totalDelta > 0) {
                const ratio = 1 - idleDelta / totalDelta;
                root.cpuRatio = Math.max(0, Math.min(1, ratio));
            }
        }

        root.lastCpuTotal = total;
        root.lastCpuIdle = idle;
    }

    function readMem(text) {
        const lines = text.split("\n");
        let total = 0;
        let available = 0;

        for (let i = 0; i < lines.length; ++i) {
            const line = lines[i];
            if (line.indexOf("MemTotal:") === 0)
                total = Number(line.trim().split(/\s+/)[1]);
            else if (line.indexOf("MemAvailable:") === 0)
                available = Number(line.trim().split(/\s+/)[1]);
        }

        if (total <= 0)
            return;

        root.memTotal = total / 1048576;
        root.memUsed = (total - available) / 1048576;
        root.memRatio = Math.max(0, Math.min(1, (total - available) / total));
    }

    function readBatteryCapacity(text) {
        const value = Number.parseInt(text.trim(), 10);
        root.batteryPercent = Number.isFinite(value) ? value : -1;
    }

    function readBatteryStatus(text) {
        root.batteryStatus = text.trim();
    }

    function readTemperature(text) {
        let value = Number.parseFloat(text.trim());
        if (!Number.isFinite(value)) {
            root.temperature = -1;
            return;
        }

        if (value > 200)
            value /= 1000;

        root.temperature = value;
    }

    FileView {
        id: statFile
        path: "/proc/stat"
        onTextChanged: root.readCpu(statFile.text())
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        onTextChanged: root.readMem(memFile.text())
    }

    FileView {
        id: tempFile
        path: root.tempPath
        onTextChanged: root.readTemperature(tempFile.text())
        onLoadFailed: root.temperature = -1
    }

    FileView {
        id: batteryCapacityFile
        path: "/sys/class/power_supply/BAT0/capacity"
        onTextChanged: root.readBatteryCapacity(batteryCapacityFile.text())
        onLoadFailed: root.batteryPercent = -1
    }

    FileView {
        id: batteryStatusFile
        path: "/sys/class/power_supply/BAT0/status"
        onTextChanged: root.readBatteryStatus(batteryStatusFile.text())
        onLoadFailed: root.batteryStatus = ""
    }

    Process {
        id: sensorProcess
        running: true
        command: [
            "sh", "-c",
            "for h in /sys/class/hwmon/hwmon*; do " +
            "[ \"$(cat \"$h/name\" 2>/dev/null)\" = coretemp ] || continue; " +
            "[ -r \"$h/temp1_input\" ] || continue; " +
            "printf '%s\\n' \"$h/temp1_input\"; exit 0; done; " +
            "for z in /sys/class/thermal/thermal_zone*; do " +
            "[ \"$(cat \"$z/type\" 2>/dev/null)\" = x86_pkg_temp ] || continue; " +
            "[ -r \"$z/temp\" ] || continue; " +
            "printf '%s\\n' \"$z/temp\"; exit 0; done; exit 1"
        ]

        stdout: StdioCollector {
            onStreamFinished: root.tempPath = this.text.trim()
        }

        onExited: {
            if (root.tempPath.length === 0)
                sensorRetry.start();
        }
    }

    Timer {
        id: refreshTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            memFile.reload();
            if (root.tempPath.length > 0)
                tempFile.reload();
        }
    }

    Timer {
        id: statTimer
        interval: root.settings ? root.settings.cpuRefreshInterval : 300
        running: true
        repeat: true
        onTriggered: statFile.reload()
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: {
            batteryCapacityFile.reload();
            batteryStatusFile.reload();
        }
    }

    Timer {
        id: sensorRetry
        interval: 30000
        onTriggered: {
            if (root.tempPath.length === 0)
                sensorProcess.running = true;
        }
    }
}
