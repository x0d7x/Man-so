import Quickshell
import Quickshell.Io
import QtQuick

// Logind sessions, shown in the island on demand (not in the power menu).
Scope {
    id: root

    property var sessions: []
    property bool loading: false
    property string lastError: ""

    function refresh() {
        if (listProcess.running)
            return;
        root.loading = true;
        root.lastError = "";
        listProcess.running = true;
    }

    function parse(text) {
        const rows = [];
        const lines = String(text).split("\n");
        for (let i = 0; i < lines.length; ++i) {
            const line = lines[i].trim();
            if (line.length === 0)
                continue;
            // loginctl list-sessions --no-legend:
            // SESSION UID USER SEAT LEADER CLASS TTY IDLE SINCE
            const f = line.split(/\s+/);
            if (f.length < 6)
                continue;
            rows.push({
                "id": f[0],
                "user": f[2],
                "seat": f[3] === "-" ? "" : f[3],
                "class": f[5],
                "tty": f.length > 6 && f[6] !== "-" ? f[6] : ""
            });
        }
        root.sessions = rows;
    }

    function summary() {
        if (root.sessions.length === 0)
            return "no sessions";
        const parts = [];
        for (let i = 0; i < root.sessions.length; ++i) {
            const s = root.sessions[i];
            parts.push(s.id + ":" + s.user + ":" + s.class);
        }
        return parts.join(" ");
    }

    Process {
        id: listProcess

        command: ["loginctl", "list-sessions", "--no-legend", "--no-pager"]

        stdout: StdioCollector {
            id: listOutput
        }

        onExited: exitCode => {
            root.loading = false;
            if (exitCode === 0) {
                root.parse(listOutput.text);
            } else {
                root.sessions = [];
                root.lastError = "loginctl failed (exit " + exitCode + ")";
            }
        }
    }
}
