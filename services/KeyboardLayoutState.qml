import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property var layouts: []
    property string currentName: ""
    property int currentIndex: -1
    property bool initialized: false
    property bool visible: false
    property bool osdEnabled: true
    property int osdTimeout: 1500
    property string lastError: ""

    readonly property string currentLabel: root.currentName.length > 0 ? root.currentName : "—"
    readonly property string positionText: root.currentIndex >= 0 && root.layouts.length > 0
        ? (root.currentIndex + 1) + " / " + root.layouts.length
        : ""

    readonly property string configPath: {
        const xdg = Quickshell.env("XDG_CONFIG_HOME");
        const base = xdg && xdg.length > 0 ? xdg : Quickshell.env("HOME") + "/.config";
        return base + "/mango/config.toml";
    }

    function rebuildLayouts() {
        const config = configFile.text();
        const rules = rulesFile.text();
        const layoutMatch = config.match(/^\s*xkb_rules_layout\s*=\s*"([^"]*)"/m);
        const variantMatch = config.match(/^\s*xkb_rules_variant\s*=\s*"([^"]*)"/m);
        const codes = layoutMatch
            ? layoutMatch[1].split(",").map(value => value.trim()).filter(value => value.length > 0)
            : [];
        const variants = variantMatch ? variantMatch[1].split(",") : [];

        const baseLabels = {};
        const variantLabels = {};
        if (rules.length > 0) {
            const start = rules.indexOf("! layout");
            const end = rules.indexOf("! option");
            const sectionText = start >= 0
                ? rules.slice(start, end >= start ? end : rules.length)
                : rules;
            const lines = sectionText.split("\n");
            for (let i = 0; i < lines.length; ++i) {
                const match = lines[i].match(/^\s{2}([A-Za-z0-9_]+)\s{2,}(.+)$/);
                if (!match)
                    continue;

                const key = match[1];
                const description = match[2].trim();
                const variantMatch = description.match(/^([A-Za-z0-9_-]+):\s*(.+)$/);
                if (variantMatch)
                    variantLabels[variantMatch[1] + "|" + key] = variantMatch[2];
                else
                    baseLabels[key] = description;
            }
        }

        const next = [];
        for (let i = 0; i < codes.length; ++i) {
            const code = codes[i];
            const variant = (variants[i] || "").trim();
            let label = variant.length > 0
                ? variantLabels[code + "|" + variant]
                : baseLabels[code];
            if (!label)
                label = baseLabels[code];
            if (!label)
                label = code.toUpperCase();
            next.push({
                "code": code,
                "variant": variant,
                "label": label
            });
        }

        root.layouts = next;
        root.updateCurrentIndex();
    }

    function updateCurrentIndex() {
        if (root.currentName.length === 0) {
            root.currentIndex = -1;
            return;
        }

        for (let i = 0; i < root.layouts.length; ++i) {
            if (root.layouts[i].label === root.currentName) {
                root.currentIndex = i;
                return;
            }
        }

        root.currentIndex = -1;
    }

    function consumeLayout(line) {
        let data = null;
        try {
            data = JSON.parse(line);
        } catch (error) {
            return;
        }
        if (!data || typeof data.layout !== "string")
            return;

        const wasInitialized = root.initialized;
        const changed = data.layout !== root.currentName;
        root.currentName = data.layout;
        root.updateCurrentIndex();
        root.initialized = true;

        if (wasInitialized && changed && root.osdEnabled)
            root.show();
    }

    function show() {
        if (!root.osdEnabled)
            return;
        root.visible = true;
        osdTimer.restart();
    }

    function switchTo(layout) {
        if (!layout || typeof layout.code !== "string" || layout.code.length === 0)
            return;
        Quickshell.execDetached(["mmsg", "dispatch", "switch_keyboard_layout," + layout.code]);
    }

    function switchNext() {
        if (root.layouts.length === 0)
            return;
        const index = root.currentIndex >= 0 ? (root.currentIndex + 1) % root.layouts.length : 0;
        root.switchTo(root.layouts[index]);
    }

    onOsdEnabledChanged: {
        if (!root.osdEnabled)
            root.visible = false;
    }

    onOsdTimeoutChanged: {
        if (root.visible)
            osdTimer.restart();
    }

    Component.onCompleted: {
        configFile.reload();
        rulesFile.reload();
        watchProcess.running = true;
    }

    FileView {
        id: configFile
        path: root.configPath
        watchChanges: true
        onTextChanged: root.rebuildLayouts()
        onLoadFailed: root.lastError = "Cannot read MangoWM config"
    }

    FileView {
        id: rulesFile
        path: "/usr/share/X11/xkb/rules/evdev.lst"
        watchChanges: false
        onTextChanged: root.rebuildLayouts()
        onLoadFailed: root.lastError = "Cannot read XKB layout list"
    }

    Process {
        id: watchProcess
        command: ["mmsg", "watch", "keyboardlayout"]
        running: true

        stdout: SplitParser {
            onRead: line => root.consumeLayout(line)
        }

        onExited: {
            restartTimer.restart();
        }
    }

    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: watchProcess.running = true
    }

    Timer {
        id: osdTimer
        interval: root.osdTimeout
        onTriggered: root.visible = false
    }
}
