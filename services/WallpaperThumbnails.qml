import Quickshell
import Quickshell.Io
import QtQuick

// Small on-disk thumbnail cache for the wallpaper picker.
// Thumbnails are generated lazily (only for delegates the layouts create),
// keyed by a hash of the source path, and evicted oldest-first above a cap.
Scope {
    id: root

    readonly property string homeDir: Quickshell.env("HOME") || ""
    readonly property string cacheDir: (Quickshell.env("XDG_CACHE_HOME") || (root.homeDir + "/.cache")) + "/maneso/wallpaper-thumbs"
    readonly property int maxCached: 600
    readonly property int maxQueued: 200
    readonly property int thumbWidth: 480

    // hash -> true for files already on disk or generated this session.
    property var available: ({})
    property var queue: []
    property bool scanning: false
    property bool scanned: false
    property bool cleanupDone: false

    signal ready(string source)

    function hash(path) {
        let value = 5381;
        for (let i = 0; i < path.length; ++i)
            value = ((value * 33) ^ path.charCodeAt(i)) >>> 0;
        return value.toString(16);
    }

    function thumbPath(source) {
        return root.cacheDir + "/" + root.hash(source) + ".jpg";
    }

    function has(source) {
        return root.available[root.hash(source)] === true;
    }

    function request(source) {
        if (!source || source.length === 0 || root.has(source))
            return;
        if (root.queue.indexOf(source) !== -1)
            return;
        if (root.queue.length >= root.maxQueued)
            return;
        root.queue = root.queue.concat([source]);
        root.pump();
    }

    function pump() {
        if (!root.scanned && !root.scanning)
            root.scan();
        if (root.queue.length === 0)
            return;
        const slots = [genA, genB];
        for (let i = 0; i < slots.length; ++i) {
            if (!slots[i].running && root.queue.length > 0) {
                const next = root.queue[0];
                root.queue = root.queue.slice(1);
                slots[i].source = next;
                slots[i].command = [
                    "ffmpeg", "-y", "-loglevel", "error",
                    "-i", next,
                    "-vf", "scale=" + root.thumbWidth + ":-2",
                    "-frames:v", "1", "-q:v", "4",
                    root.thumbPath(next)
                ];
                slots[i].running = true;
            }
        }
    }

    function finish(process, exitCode) {
        const source = process.source;
        process.source = "";
        if (exitCode === 0 && source.length > 0) {
            const map = {};
            for (const key in root.available)
                map[key] = root.available[key];
            map[root.hash(source)] = true;
            root.available = map;
            root.ready(source);
        }
        root.pump();
    }

    function scan() {
        // One listing per session: scanning again from pump() would respawn the
        // listing processes forever.
        if (root.scanned || root.scanning)
            return;
        root.scanning = true;
        mkdirProcess.running = true;
    }

    function loadCacheList(text) {
        const map = {};
        const names = text.split("\n");
        for (let i = 0; i < names.length; ++i) {
            const name = names[i].trim();
            if (name.endsWith(".jpg"))
                map[name.slice(0, -4)] = true;
        }
        root.available = map;
    }

    function evict() {
        if (root.cleanupDone)
            return;
        root.cleanupDone = true;
        // Keep the newest maxCached thumbnails, drop the rest in one pass.
        evictProcess.command = [
            "sh", "-c",
            "find \"$1\" -maxdepth 1 -name '*.jpg' -printf '%T@ %p\\n' 2>/dev/null"
                + " | sort -n | head -n -" + root.maxCached
                + " | cut -d' ' -f2- | tr '\\n' '\\0' | xargs -0 -r rm -f",
            "maneso-thumb-evict", root.cacheDir
        ];
        evictProcess.running = true;
    }

    Component.onCompleted: root.scan()

    Process {
        id: mkdirProcess
        command: ["mkdir", "-p", root.cacheDir]

        onExited: listProcess.running = true
    }

    Process {
        id: listProcess
        command: ["ls", "-1", root.cacheDir]
        stdout: StdioCollector {
            id: listOutput
        }

        onExited: exitCode => {
            root.scanning = false;
            root.scanned = true;
            if (exitCode === 0)
                root.loadCacheList(listOutput.text);
            root.evict();
            root.pump();
        }
    }

    Process {
        id: evictProcess
    }

    Process {
        id: genA
        property string source: ""
        stderr: StdioCollector { id: genAError }

        onExited: exitCode => root.finish(genA, exitCode)
    }

    Process {
        id: genB
        property string source: ""
        stderr: StdioCollector { id: genBError }

        onExited: exitCode => root.finish(genB, exitCode)
    }
}
