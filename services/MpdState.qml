import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property string socketPath: "/tmp/mpd_socket"
    property string dbusName: "mpd"
    property string identity: "MPD"
    property bool connected: false
    property bool initialized: false
    property bool changed: false
    property int uniqueId: 0
    property string trackTitle: ""
    property string trackArtist: ""
    property string trackAlbum: ""
    property string trackAlbumArtist: ""
    property string trackArtUrl: ""
    property string filePath: ""
    property string playbackState: "stop"
    property real position: 0
    property real length: 0
    property bool isPlaying: false
    property bool hasPlayer: false
    property bool canGoNext: false
    property bool canGoPrevious: false
    property bool canTogglePlaying: false
    property bool canSeek: false
    property var statusFields: ({})
    property var songFields: ({})
    property string pendingCommand: ""
    property int artworkId: -1
    property string pendingArtworkPath: ""
    property int pendingArtworkId: -1

    function fieldValue(text) {
        const index = text.indexOf(": ");
        if (index < 0)
            return ["", ""];
        return [text.substring(0, index), text.substring(index + 2)];
    }

    function basename(path) {
        if (!path)
            return "";
        const parts = path.split("/");
        return parts[parts.length - 1];
    }

    function parseResponse(text) {
        const lines = text.split("\n");
        let section = "status";
        const status = {};
        const song = {};

        for (let i = 0; i < lines.length; ++i) {
            const line = lines[i].trim();
            if (line.length === 0 || line.indexOf("OK MPD") === 0)
                continue;
            if (line === "OK") {
                if (section === "status")
                    section = "song";
                continue;
            }

            const pair = root.fieldValue(line);
            if (pair[0].length === 0)
                continue;
            if (section === "status")
                status[pair[0]] = pair[1];
            else
                song[pair[0]] = pair[1];
        }

        root.statusFields = status;
        root.songFields = song;
        root.applyState();
    }

    function applyState() {
        const status = root.statusFields;
        const song = root.songFields;
        const nextState = status["state"] || "stop";
        const nextTitle = song["Title"] || song["Name"] || root.basename(song["file"]);
        const nextArtist = song["Artist"] || song["AlbumArtist"] || "";
        const nextAlbum = song["Album"] || "";
        const nextAlbumArtist = song["AlbumArtist"] || "";
        const nextLength = Number(song["duration"] || song["Time"] || 0);
        const nextPosition = Number(status["elapsed"] || 0);
        const nextSongId = Number(song["Id"] || status["songid"] || -1);
        const nextPlaying = nextState === "play";
        const changedTrack = root.uniqueId !== nextSongId;
        const nextFile = song["file"] || "";

        root.playbackState = nextState;
        root.isPlaying = nextPlaying;
        root.hasPlayer = nextState !== "stop" && nextSongId >= 0;
        root.trackTitle = nextTitle;
        root.trackArtist = nextArtist;
        root.trackAlbum = nextAlbum;
        root.trackAlbumArtist = nextAlbumArtist;
        root.filePath = nextFile;
        root.length = Number.isFinite(nextLength) ? nextLength : 0;
        root.position = Number.isFinite(nextPosition) ? nextPosition : 0;
        root.uniqueId = nextSongId;
        root.canGoNext = Number(status["playlistlength"] || 0) > 1;
        root.canGoPrevious = Number(status["song"] || 0) > 0 || root.position > 3;
        root.canTogglePlaying = true;
        root.canSeek = true;
        root.connected = true;

        if (changedTrack) {
            root.trackArtUrl = "";
            if (nextFile.length > 0)
                root.extractArtwork(nextFile, nextSongId);
        }

        root.initialized = true;
        root.changed = false;
    }

    function requestUpdate() {
        if (!refreshProcess.running)
            refreshProcess.running = true;
    }

    function sendCommand(command) {
        if (controlProcess.running) {
            root.pendingCommand = command;
            return;
        }

        controlProcess.command = [
            "sh", "-c",
            "printf '" + command + "\\nclose\\n' | ncat -U " + root.socketPath
        ];
        controlProcess.running = true;
    }

    function togglePlaying() {
        root.sendCommand(root.isPlaying ? "pause 1" : "play");
    }

    function next() {
        root.sendCommand("next");
    }

    function previous() {
        root.sendCommand("previous");
    }

    function seekTo(fraction) {
        if (root.length <= 0)
            return;
        const target = Math.max(0, Math.min(1, fraction)) * root.length;
        root.position = target;
        root.sendCommand("seekcur " + target.toFixed(3));
    }

    function extractArtwork(path, id) {
        if (artProcess.running) {
            root.pendingArtworkPath = path;
            root.pendingArtworkId = id;
            return;
        }

        root.artworkId = id;
        artProcess.command = [
            "ffmpeg", "-v", "error", "-y", "-i", path,
            "-map", "0:v:0", "-frames:v", "1",
            "/tmp/maneso-mpd-cover-" + id + ".png"
        ];
        artProcess.running = true;
    }

    function handleIdleLine(line) {
        if (line.indexOf("OK MPD") === 0) {
            idleProcess.write("idle player\n");
            return;
        }
        if (line.indexOf("changed:") === 0) {
            root.changed = true;
            return;
        }
        if (line === "OK") {
            if (root.changed)
                root.requestUpdate();
            root.changed = false;
            idleProcess.write("idle player\n");
        }
    }

    Process {
        id: idleProcess
        command: ["ncat", "-U", root.socketPath]
        stdinEnabled: true
        running: true

        stdout: SplitParser {
            onRead: data => root.handleIdleLine(data)
        }

        onExited: {
            root.connected = false;
            idleRestart.restart();
        }
    }

    Process {
        id: refreshProcess
        command: [
            "sh", "-c",
            "printf 'status\\ncurrentsong\\nclose\\n' | ncat -U " + root.socketPath
        ]

        stdout: StdioCollector {
            onStreamFinished: root.parseResponse(this.text)
        }
    }

    Process {
        id: artProcess

        onExited: exitCode => {
            if (exitCode === 0)
                root.trackArtUrl = "file:///tmp/maneso-mpd-cover-" + root.artworkId + ".png";
            else
                root.trackArtUrl = "";

            if (root.pendingArtworkPath.length > 0) {
                const path = root.pendingArtworkPath;
                const id = root.pendingArtworkId;
                root.pendingArtworkPath = "";
                root.pendingArtworkId = -1;
                root.extractArtwork(path, id);
            }
        }
    }

    Process {
        id: controlProcess

        onExited: {
            if (root.pendingCommand.length > 0) {
                const command = root.pendingCommand;
                root.pendingCommand = "";
                root.sendCommand(command);
            }
        }
    }

    Timer {
        id: idleRestart
        interval: 1000
        onTriggered: idleProcess.running = true
    }

    Component.onCompleted: root.requestUpdate()
}
