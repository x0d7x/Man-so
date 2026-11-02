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
    readonly property int maxSkipAttempts: 10
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
    property int skipAttempts: 0
    property var knownOutputs: null
    property var newOutputs: []
    property int restoreAttempts: 0
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
        root.skipAttempts = 0;
        return root.apply(target, "manual");
    }

    // Public entry points start a fresh skip chain. Retries call pickRandom/step directly.
    function randomWallpaper() {
        root.skipAttempts = 0;
        return root.pickRandom("random");
    }

    function nextWallpaper() {
        root.skipAttempts = 0;
        return root.step(1, "", "next");
    }

    function previousWallpaper() {
        root.skipAttempts = 0;
        return root.step(-1, "", "previous");
    }

    function pickRandom(origin) {
        const list = root.files;
        if (list.length === 0) {
            root.lastError = "no images in " + root.directory;
            root.refresh();
            return false;
        }
        const pool = list.filter(p => p !== root.currentPath && p !== root.lastFailedPath);
        const choices = pool.length > 0 ? pool : list;
        return root.apply(choices[Math.floor(Math.random() * choices.length)], origin);
    }

    // Steps from `from` (the current image when empty). Retries pass the failed file
    // as `from`, so a broken image is skipped instead of being picked again.
    function step(delta, from, origin) {
        const list = root.files;
        if (list.length === 0) {
            root.lastError = "no images in " + root.directory;
            root.refresh();
            return false;
        }
        const base = from.length > 0 ? from : root.currentPath;
        let index = list.indexOf(base);
        if (index < 0)
            index = delta > 0 ? 0 : list.length - 1;
        else
            index = (index + delta + list.length) % list.length;
        return root.apply(list[index], origin);
    }

    readonly property bool usesQuickshell: root.settings ? root.settings.wallpaperBackend === "quickshell" : false

    function apply(path, origin) {
        // The quickshell backend renders in-process: no command, no queue.
        if (root.usesQuickshell) {
            root.currentPath = path;
            root.lastError = "";
            root.skipAttempts = 0;
            root.lastFailedPath = "";
            root.saveState();
            root.queueHooks(path);
            return true;
        }
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
            root.skipAttempts = 0;
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
            root.skipAttempts = 0;
            root.apply(next, nextOrigin);
        } else if (exitCode !== 0 && origin !== "manual") {
            root.retryAfterFailure(origin, path);
        }
    }

    // An automatic or stepping request hit an unreadable file: try the next candidate,
    // up to maxSkipAttempts times, then stop with the last error.
    function retryAfterFailure(origin, failedPath) {
        if (root.skipAttempts >= root.maxSkipAttempts) {
            root.lastError = "stopped after " + root.skipAttempts + " unreadable images; " + root.lastError;
            root.skipAttempts = 0;
            return;
        }
        root.skipAttempts += 1;
        if (origin === "next")
            root.step(1, failedPath, "next");
        else if (origin === "previous")
            root.step(-1, failedPath, "previous");
        else
            root.pickRandom(origin);
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

    Component.onCompleted: {
        mkdirProcess.running = true;
        root.knownOutputs = root.screenNames();
    }

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

    // Hotplug: restore the current image on outputs that appear later. Only the awww
    // backend needs this; the quickshell layer follows Quickshell.screens by itself.
    function screenNames() {
        const names = [];
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; ++i) {
            if (screens[i] && screens[i].name)
                names.push(screens[i].name);
        }
        return names;
    }

    function handleScreensChanged() {
        const names = root.screenNames();
        const known = root.knownOutputs;
        root.knownOutputs = names;
        if (known === null)
            return;
        for (let i = 0; i < names.length; ++i) {
            if (known.indexOf(names[i]) < 0 && root.newOutputs.indexOf(names[i]) < 0)
                root.newOutputs = root.newOutputs.concat([names[i]]);
        }
        if (root.newOutputs.length > 0)
            restoreTimer.restart();
    }

    function restoreNewOutputs() {
        if (restoreProcess.running) {
            restoreTimer.restart();
            return;
        }
        const outputs = root.newOutputs;
        if (outputs.length === 0)
            return;
        if (!root.settings || root.settings.wallpaperBackend !== "awww" || root.currentPath.length === 0) {
            root.newOutputs = [];
            return;
        }
        restoreProcess.command = [
            "awww", "img",
            "--resize", root.awwwResize(root.settings.wallpaperFit),
            "--transition-type", "none",
            "--transition-duration", "0",
            "--transition-fps", "60",
            "--outputs", outputs.join(","),
            root.currentPath
        ];
        restoreProcess.running = true;
    }

    Connections {
        target: Quickshell

        function onScreensChanged() {
            root.handleScreensChanged();
        }
    }

    Timer {
        id: restoreTimer
        // Give the compositor a moment to finish creating the new output.
        interval: 500
        onTriggered: root.restoreNewOutputs()
    }

    Process {
        id: restoreProcess
        stderr: StdioCollector {
            id: restoreError
        }

        onExited: exitCode => {
            if (exitCode === 0) {
                root.newOutputs = [];
                root.restoreAttempts = 0;
            } else if (root.restoreAttempts < 4) {
                // The output may not be ready yet; retry the same outputs shortly.
                root.restoreAttempts += 1;
                restoreTimer.restart();
            } else {
                root.newOutputs = [];
                root.restoreAttempts = 0;
                root.lastError = "restore to new output failed: " + restoreError.text.trim();
            }
        }
    }

    Timer {
        id: rotateTimer
        interval: Math.max(1, root.rotateMinutes) * 60000
        repeat: true
        running: root.ready && root.rotateMinutes > 0
        onTriggered: {
            root.skipAttempts = 0;
            root.pickRandom("rotation");
        }
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
