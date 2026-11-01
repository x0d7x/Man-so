import Quickshell
import Quickshell.Io
import QtQuick

// Wallpaper orchestration: directory listing, backend apply, post-apply hooks,
// random rotation and the last applied path. Rendering is delegated to the
// backend (awww or a user command). Only the last path is persisted.
Scope {
    id: root

    property var settings
    property var mango

    readonly property var imageExtensions: ["jpg", "jpeg", "png", "webp", "gif"]
    readonly property int maxRotationAttempts: 5
    readonly property string homeDir: Quickshell.env("HOME") || ""
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (root.homeDir + "/.local/state")) + "/maneso"
    readonly property string statePath: root.stateDir + "/wallpaper.json"
    readonly property bool ready: root.settings ? root.settings.initialized : false
    readonly property string directory: root.trimTrailingSlash(root.expandPath(root.settings ? root.settings.wallpaperDirectory : ""))
    readonly property int rotateMinutes: root.settings ? root.settings.wallpaperRotateMinutes : 0

    property var files: []
    property string currentPath: ""
    property string lastError: ""
    property bool listing: false
    property bool listQueued: false

    property string activePath: ""
    property string activeOrigin: "manual"
    property string pendingPath: ""
    property string pendingOrigin: "manual"
    property string lastFailedPath: ""
    property int rotationAttempts: 0
    property var hookQueue: []

    // Veila reads its lock background from this file; keep it in sync.
    readonly property string veilaSyncScript: "mkdir -p \"$HOME/.cache/veila\" && "
        + "cp -f -- \"$1\" \"$HOME/.cache/veila/wallpaper.jpg.tmp\" && "
        + "mv -f -- \"$HOME/.cache/veila/wallpaper.jpg.tmp\" \"$HOME/.cache/veila/wallpaper.jpg\""

    function expandPath(value) {
        if (typeof value !== "string")
            return "";
        const trimmed = value.trim();
        if (trimmed.startsWith("~/"))
            return root.homeDir + trimmed.slice(1);
        return trimmed;
    }

    function trimTrailingSlash(path) {
        return path.length > 1 ? path.replace(/\/+$/, "") : path;
    }

    function isImage(path) {
        const dot = path.lastIndexOf(".");
        if (dot < 0)
            return false;
        return root.imageExtensions.indexOf(path.slice(dot + 1).toLowerCase()) !== -1;
    }

    function shellQuote(value) {
        return "'" + String(value).split("'").join("'\\''") + "'";
    }

    function awwwResize(fit) {
        if (fit === "fit")
            return "fit";
        if (fit === "stretch")
            return "stretch";
        if (fit === "center" || fit === "tile")
            return "no";
        return "crop";
    }

    function refresh() {
        if (!root.ready)
            return;
        if (listProcess.running) {
            root.listQueued = true;
            return;
        }
        if (root.directory.length === 0)
            return;
        listProcess.command = ["find", root.directory, "-maxdepth", "1", "-type", "f", "-print"];
        root.listing = true;
        listProcess.running = true;
    }

    function setPath(path) {
        const target = root.expandPath(path);
        if (target.length === 0 || target.charAt(0) !== "/") {
            root.lastError = "wallpaper path must be absolute";
            return false;
        }
        if (!root.isImage(target)) {
            root.lastError = "not a supported image: " + target;
            return false;
        }
        return root.apply(target, "manual");
    }

    function randomWallpaper() {
        const list = root.files;
        if (list.length === 0) {
            root.lastError = "no images in " + root.directory;
            root.refresh();
            return false;
        }
        const pool = list.filter(p => p !== root.currentPath && p !== root.lastFailedPath);
        const choices = pool.length > 0 ? pool : list;
        return root.apply(choices[Math.floor(Math.random() * choices.length)], "manual");
    }

    function stepWallpaper(delta) {
        const list = root.files;
        if (list.length === 0) {
            root.lastError = "no images in " + root.directory;
            root.refresh();
            return false;
        }
        let index = list.indexOf(root.currentPath);
        if (index < 0)
            index = delta > 0 ? 0 : list.length - 1;
        else
            index = (index + delta + list.length) % list.length;
        return root.apply(list[index], "manual");
    }

    function nextWallpaper() {
        return root.stepWallpaper(1);
    }

    function previousWallpaper() {
        return root.stepWallpaper(-1);
    }

    function apply(path, origin) {
        if (backendProcess.running) {
            root.pendingPath = path;
            root.pendingOrigin = origin;
            return true;
        }
        const command = root.backendCommand(path);
        if (!command)
            return false;
        root.activePath = path;
        root.activeOrigin = origin;
        backendProcess.command = command;
        backendProcess.running = true;
        return true;
    }

    function backendCommand(path) {
        if (!root.settings)
            return null;

        if (root.settings.wallpaperBackend === "command") {
            const template = root.settings.wallpaperCommand;
            if (typeof template !== "string" || template.trim().length === 0) {
                root.lastError = "command backend has no command template";
                return null;
            }
            return ["sh", "-c", template.split("{path}").join(root.shellQuote(path))];
        }

        const args = [
            "awww", "img",
            "--resize", root.awwwResize(root.settings.wallpaperFit),
            "--transition-type", root.settings.wallpaperTransition,
            "--transition-duration", String(root.settings.wallpaperTransitionDuration),
            "--transition-fps", "60"
        ];
        if (root.settings.wallpaperTarget === "focused") {
            const output = root.mango ? root.mango.focusedMonitor : "";
            if (!output) {
                root.lastError = "no focused output for wallpaper target";
                return null;
            }
            args.push("--outputs", output);
        }
        args.push(path);
        return args;
    }

    function handleBackendExit(exitCode) {
        const origin = root.activeOrigin;
        const path = root.activePath;
        root.activePath = "";

        if (exitCode === 0) {
            root.currentPath = path;
            root.lastError = "";
            root.rotationAttempts = 0;
            root.lastFailedPath = "";
            root.saveState();
            root.queueHooks(path);
        } else {
            const detail = backendError.text.trim();
            root.lastError = "backend failed (exit " + exitCode + ")" + (detail.length > 0 ? ": " + detail : "");
            root.lastFailedPath = path;
        }

        if (root.pendingPath.length > 0) {
            const next = root.pendingPath;
            const nextOrigin = root.pendingOrigin;
            root.pendingPath = "";
            root.apply(next, nextOrigin);
        } else if (exitCode !== 0 && origin === "rotation" && root.rotationAttempts < root.maxRotationAttempts) {
            root.rotationAttempts += 1;
            root.randomWallpaper();
        }
    }

    function queueHooks(path) {
        const queue = [];
        if (root.settings.wallpaperMatugen)
            queue.push(["matugen", "image", path, "--source-color-index", "0", "-m", "dark"]);
        if (root.settings.wallpaperVeilaSync)
            queue.push(["sh", "-c", root.veilaSyncScript, "maneso-veila-sync", path]);
        const custom = root.settings.wallpaperHooks || [];
        for (let i = 0; i < custom.length; ++i)
            queue.push(["sh", "-c", String(custom[i]).split("{path}").join(root.shellQuote(path))]);

        // Newest request wins: a queued older set of hooks is dropped.
        root.hookQueue = queue;
        root.runNextHook();
    }

    function runNextHook() {
        if (hookProcess.running || root.hookQueue.length === 0)
            return;
        const queue = root.hookQueue.slice();
        const command = queue.shift();
        root.hookQueue = queue;
        hookProcess.command = command;
        hookProcess.running = true;
    }

    function saveState() {
        stateFile.setText(JSON.stringify({ "version": 1, "currentPath": root.currentPath }, null, 2) + "\n");
    }

    function loadState(text) {
        if (!text || text.trim().length === 0)
            return;
        try {
            const parsed = JSON.parse(text);
            if (parsed && typeof parsed.currentPath === "string")
                root.currentPath = parsed.currentPath;
        } catch (error) {
            console.error("Failed to parse wallpaper state:", error);
        }
    }

    function statusText() {
        const parts = [
            "backend=" + (root.settings ? root.settings.wallpaperBackend : "unknown"),
            "directory=" + root.directory,
            "images=" + root.files.length,
            "current=" + (root.currentPath.length > 0 ? root.currentPath : "none"),
            "rotate=" + root.rotateMinutes + "m",
            "busy=" + (backendProcess.running ? "true" : "false")
        ];
        if (root.lastError.length > 0)
            parts.push("error=" + root.lastError);
        return parts.join(" ");
    }

    onDirectoryChanged: root.refresh()
    onReadyChanged: root.refresh()

    Component.onCompleted: mkdirProcess.running = true

    Process {
        id: mkdirProcess
        command: ["mkdir", "-p", root.stateDir]
    }

    Process {
        id: listProcess
        stdout: StdioCollector {
            id: listOutput
        }

        onExited: exitCode => {
            root.listing = false;
            if (exitCode !== 0) {
                root.files = [];
                root.lastError = "wallpaper directory unreadable: " + root.directory;
            } else {
                const lines = listOutput.text.split("\n");
                const images = [];
                for (let i = 0; i < lines.length; ++i) {
                    if (lines[i].length > 0 && root.isImage(lines[i]))
                        images.push(lines[i]);
                }
                images.sort();
                root.files = images;
            }

            if (root.listQueued) {
                root.listQueued = false;
                root.refresh();
            }
        }
    }

    Process {
        id: backendProcess
        stderr: StdioCollector {
            id: backendError
        }

        onExited: exitCode => root.handleBackendExit(exitCode)
    }

    Process {
        id: hookProcess
        stderr: StdioCollector {
            id: hookError
        }

        onExited: exitCode => {
            if (exitCode !== 0)
                root.lastError = "hook failed (exit " + exitCode + "): " + hookError.text.trim();
            root.runNextHook();
        }
    }

    Timer {
        id: rotateTimer
        interval: Math.max(1, root.rotateMinutes) * 60000
        repeat: true
        running: root.ready && root.rotateMinutes > 0
        onTriggered: root.randomWallpaper()
    }

    FileView {
        id: stateFile
        path: root.statePath
        atomicWrites: true
        watchChanges: false
        printErrors: false

        onLoaded: root.loadState(text())
        onSaveFailed: error => root.lastError = "state save failed: " + FileViewError.toString(error)
    }
}
